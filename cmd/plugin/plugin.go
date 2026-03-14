// Copyright (C) 2026 stencil-golang contributors
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

// Package main wraps the plugin logic so stencil can call it.
package main

import (
	"context"
	"os"

	"github.com/rgst-io/stencil-golang/internal/plugin"
	"go.rgst.io/jaredallard/slogext/v2"
	"go.rgst.io/stencil/v2/pkg/extensions/apiv1"
)

// main starts the stencil-golang plugin
func main() {
	ctx := context.Background()
	log := slogext.New()

	if err := apiv1.NewExtensionImplementation(plugin.New(ctx), log); err != nil {
		log.WithError(err).Error("failed to create extension")
		os.Exit(1)
	}
}
