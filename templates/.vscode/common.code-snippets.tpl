{{- define "code-snippets.copyright.Apache-2.0" }}
Licensed under the Apache License, Version 2.0 (the \"License\");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an \"AS IS\" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
{{- end }}

{{- define "code-snippets.copyright.GPL-3.0" }}
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
{{- end }}

{{- define "code-snippets.copyright.LGPL-3.0" }}
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this program. If not, see
<https://www.gnu.org/licenses/>.
{{- end }}

{{- define "code-snippets.copyright.AGPL-3.0" }}
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
{{- end }}

{{- define "code-snippets.copyright.MIT" }}
This work is licensed under the terms of the MIT license. For a copy,
see <https://opensource.org/licenses/MIT>.
{{- end }}

# Handled by the copyright handler in the below subtemplate.
{{ define "code-snippets.copyright.Proprietary" }}{{ end }}


{{ define "code-snippets.copyright" }}
{{- $licenseTextSlice := splitList "\n" .License.Body -}}
{
  "Copyright": {
    "description": "Inserts a copyright header",
    "prefix": ["license", "copy", "copyright"],
		"body": [
			{{- if not (eq .License.Name "Proprietary") }}
			"// Copyright (C) ${CURRENT_YEAR} {{ .Config.Name }} contributors",
			{{- else }}
			"// Copyright (C) ${CURRENT_YEAR} {{ stencil.arg "copyrightHolder" }}. All rights reserved.",
			{{- end }}
			{{- range $i, $line := $licenseTextSlice }}
			{{- /* Skip final new lines */}}
			{{- if and (eq (add $i 1) (len $licenseTextSlice)) (eq $line "") }}{{ continue }}{{ end }}
			{{- if not (eq (len $line) 0) }}
			{{- $line = printf " %s" $line }}
			{{- end }}
			"//{{ $line }}",
			{{- end }}
			{{- if not (eq .License.Name "Proprietary") }}
			"//",
			"// SPDX-License-Identifier: {{ .License.Name }}",
			{{- end }}
			"",
		]
	}
}
{{ end }}

{{ $license := stencil.Arg "license" }}
{{ $licenseObj := (dict
	"Name" $license
	"Body" ""
)}}
{{ $inputs := (dict
	"License" $licenseObj
	"Config" .Config
)}}
{{ set $licenseObj "Body" (stencil.ApplyTemplate (list "code-snippets" "copyright" $license | join ".") $inputs) }}
{{ file.SetContents (stencil.ApplyTemplate "code-snippets.copyright" $inputs) }}
