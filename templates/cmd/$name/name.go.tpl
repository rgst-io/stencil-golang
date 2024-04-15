{{ file.Skip "Generates command files" }}

{{- define "cmd" }}
package main

func main() {
  // Your logic here
}

{{- end }}

{{ $cmds := stencil.Arg "commands" | default (list .Config.Name) }}
{{ range $cmds }}
{{ file.Create (printf "cmd/%s/%s.go" . .) 0600 (now) }}
{{ file.SetContents (stencil.ApplyTemplate "cmd" .) }}

# Static until we have a framework.
{{ file.Static }}
{{ end }}