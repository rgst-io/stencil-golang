// Copyright (C) 2025 stencil-golang contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
//
// SPDX-License-Identifier: GPL-3.0

package plugin

import (
	"fmt"

	"dario.cat/mergo"
	"go.rgst.io/stencil/v2/pkg/extensions/apiv1"
)

// Merge merges objects together and returns them. Equal to calling
// [mergo.Merge] with [merge.WithOverride].
func (i *Instance) Merge(exec *apiv1.TemplateFunctionExec) (any, error) {
	if len(exec.Arguments) == 0 {
		return nil, nil
	}

	r, ok := exec.Arguments[0].(map[string]any)
	if !ok {
		return nil, fmt.Errorf("expected argument to be of type map[string]any, got %T", exec.Arguments[0])
	}

	for i := range exec.Arguments[1:] {
		pos := i + 1

		arg, ok := exec.Arguments[pos].(map[string]any)
		if !ok {
			return nil, fmt.Errorf("expected argument to be of type map[string]any, got %T", exec.Arguments[pos])
		}

		if err := mergo.Merge(&r, arg, mergo.WithOverride); err != nil {
			return nil, fmt.Errorf("failed to merge: %w", err)
		}
	}

	return r, nil
}
