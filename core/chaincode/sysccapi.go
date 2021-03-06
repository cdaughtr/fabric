/*
Copyright IBM Corp. 2016 All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

		 http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package chaincode

import (
	"fmt"

	"golang.org/x/net/context"

	"github.com/hyperledger/fabric/common/util"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/core/container/inproccontroller"
	"github.com/hyperledger/fabric/core/ledger"
	"github.com/hyperledger/fabric/core/peer"

	"github.com/op/go-logging"
	"github.com/spf13/viper"

	pb "github.com/hyperledger/fabric/protos/peer"
)

var sysccLogger = logging.MustGetLogger("sysccapi")

// SystemChaincode defines the metadata needed to initialize system chaincode
// when the fabric comes up. SystemChaincodes are installed by adding an
// entry in importsysccs.go
type SystemChaincode struct {
	//Global, once only not tied to chains. Such chaincodes cannot
	//save state in the ledger. CSCC is an example
	ChainlessCC bool

	// Enabled a convenient switch to enable/disable system chaincode without
	// having to remove entry from importsysccs.go
	Enabled bool

	//Unique name of the system chaincode
	Name string

	//Path to the system chaincode; currently not used
	Path string

	//InitArgs initialization arguments to startup the system chaincode
	InitArgs [][]byte

	// Chaincode is the actual chaincode object
	Chaincode shim.Chaincode
}

// RegisterSysCC registers the given system chaincode with the peer
func RegisterSysCC(syscc *SystemChaincode) error {
	if !syscc.Enabled || !isWhitelisted(syscc) {
		sysccLogger.Info(fmt.Sprintf("system chaincode (%s,%s,%t) disabled", syscc.Name, syscc.Path, syscc.Enabled))
		return nil
	}

	err := inproccontroller.Register(syscc.Path, syscc.Chaincode)
	if err != nil {
		//if the type is registered, the instance may not be... keep going
		if _, ok := err.(inproccontroller.SysCCRegisteredErr); !ok {
			errStr := fmt.Sprintf("could not register (%s,%v): %s", syscc.Path, syscc, err)
			sysccLogger.Error(errStr)
			return fmt.Errorf(errStr)
		}
	}

	sysccLogger.Infof("system chaincode %s(%s) registered", syscc.Name, syscc.Path)
	return err
}

// deploySysCC deploys the given system chaincode on a chain
func deploySysCC(chainID string, syscc *SystemChaincode) error {
	if !syscc.Enabled || !isWhitelisted(syscc) {
		sysccLogger.Info(fmt.Sprintf("system chaincode (%s,%s) disabled", syscc.Name, syscc.Path))
		return nil
	}

	if chainID == "" && !syscc.ChainlessCC {
		return fmt.Errorf("cannot deploy system chaincode %s without chain id", syscc.Name)
	} else if chainID != "" && syscc.ChainlessCC {
		return fmt.Errorf("cannot deploy chainless system chaincode %s with chain id %s", syscc.Name, chainID)
	}

	var err error

	ctxt := context.Background()
	if !syscc.ChainlessCC {
		lgr := peer.GetLedger(chainID)
		var txsim ledger.TxSimulator
		if txsim, err = lgr.NewTxSimulator(); err != nil {
			return err
		}

		ctxt = context.WithValue(ctxt, TXSimulatorKey, txsim)

		defer txsim.Done()
	}

	chaincodeID := &pb.ChaincodeID{Path: syscc.Path, Name: syscc.Name}
	spec := &pb.ChaincodeSpec{Type: pb.ChaincodeSpec_Type(pb.ChaincodeSpec_Type_value["GOLANG"]), ChaincodeID: chaincodeID, Input: &pb.ChaincodeInput{Args: syscc.InitArgs}}

	// First build and get the deployment spec
	chaincodeDeploymentSpec, err := buildSysCC(ctxt, spec)

	if err != nil {
		sysccLogger.Error(fmt.Sprintf("Error deploying chaincode spec: %v\n\n error: %s", spec, err))
		return err
	}

	txid := util.GenerateUUID()

	version := util.GetSysCCVersion()
	cccid := NewCCContext(chainID, chaincodeDeploymentSpec.ChaincodeSpec.ChaincodeID.Name, version, txid, true, nil)

	_, _, err = Execute(ctxt, cccid, chaincodeDeploymentSpec)

	sysccLogger.Infof("system chaincode %s/%s(%s) deployed", syscc.Name, chainID, syscc.Path)

	return err
}

// deDeploySysCC stops the system chaincode and deregisters it from inproccontroller
func deDeploySysCC(chainID string, syscc *SystemChaincode) error {
	chaincodeID := &pb.ChaincodeID{Path: syscc.Path, Name: syscc.Name}
	spec := &pb.ChaincodeSpec{Type: pb.ChaincodeSpec_Type(pb.ChaincodeSpec_Type_value["GOLANG"]), ChaincodeID: chaincodeID, Input: &pb.ChaincodeInput{Args: syscc.InitArgs}}

	ctx := context.Background()
	// First build and get the deployment spec
	chaincodeDeploymentSpec, err := buildSysCC(ctx, spec)

	if err != nil {
		sysccLogger.Error(fmt.Sprintf("Error deploying chaincode spec: %v\n\n error: %s", spec, err))
		return err
	}

	chaincodeSupport := GetChain()
	if chaincodeSupport != nil {
		version := util.GetSysCCVersion()
		cccid := NewCCContext(chainID, syscc.Name, version, "", true, nil)
		err = chaincodeSupport.Stop(ctx, cccid, chaincodeDeploymentSpec)
	}

	return err
}

// buildLocal builds a given chaincode code
func buildSysCC(context context.Context, spec *pb.ChaincodeSpec) (*pb.ChaincodeDeploymentSpec, error) {
	var codePackageBytes []byte
	chaincodeDeploymentSpec := &pb.ChaincodeDeploymentSpec{ExecEnv: pb.ChaincodeDeploymentSpec_SYSTEM, ChaincodeSpec: spec, CodePackage: codePackageBytes}
	return chaincodeDeploymentSpec, nil
}

func isWhitelisted(syscc *SystemChaincode) bool {
	chaincodes := viper.GetStringMapString("chaincode.system")
	val, ok := chaincodes[syscc.Name]
	enabled := val == "enable" || val == "true" || val == "yes"
	return ok && enabled
}
