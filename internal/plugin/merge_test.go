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
package plugin_test

import (
	"testing"

	"github.com/rgst-io/stencil-golang/internal/plugin"
	"go.rgst.io/stencil/v2/pkg/extensions/apiv1"
	"gotest.tools/v3/assert"
)

func TestCanMergeObjects(t *testing.T) {
	p := plugin.New(t.Context())

	merged, err := p.Merge(&apiv1.TemplateFunctionExec{
		Arguments: []any{
			map[string]any{"a": "b"},
			map[string]any{"b": "c"},
		},
	})
	assert.NilError(t, err)
	assert.DeepEqual(t, merged, map[string]any{
		"a": "b",
		"b": "c",
	})
}

func TestCannotMergeUnrelatedObjects(t *testing.T) {
	p := plugin.New(t.Context())

	_, err := p.Merge(&apiv1.TemplateFunctionExec{
		Arguments: []any{
			map[string]any{"a": "b"},
			map[int]any{1: "c"},
		},
	})
	assert.ErrorContains(t, err, "expected argument to be of type map[string]any, got map[int]interface {}")
}
