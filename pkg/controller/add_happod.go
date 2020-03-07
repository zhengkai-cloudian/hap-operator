package controller

import (
	"github.com/operator-framework/operator-sdk/podset-operator/pkg/controller/happod"
)

func init() {
	// AddToManagerFuncs is a list of functions to create controllers and add them to a manager.
	AddToManagerFuncs = append(AddToManagerFuncs, happod.Add)
}
