package controller

import (
	"hap-operator/pkg/controller/hapoperator"
)

func init() {
	// AddToManagerFuncs is a list of functions to create controllers and add them to a manager.
	AddToManagerFuncs = append(AddToManagerFuncs, hapoperator.Add)
}
