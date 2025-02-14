{{- file.Static }}
module {{ stencil.Include "importPath" }}/{{ stencil.Arg "org" }}/{{ .Config.Name }}

go 1.23
