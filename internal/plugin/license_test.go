package plugin_test

import (
	"testing"

	"github.com/google/go-github/v73/github"
	"github.com/rgst-io/stencil-golang/internal/plugin"
	"go.rgst.io/stencil/v2/pkg/extensions/apiv1"
	"gotest.tools/v3/assert"
)

func TestCanGetLicenseByName(t *testing.T) {
	p := plugin.New(t.Context())

	license, err := p.GetLicense(&apiv1.TemplateFunctionExec{
		Arguments: []any{"LGPL-3.0"},
	})
	assert.NilError(t, err)
	assert.Equal(t, license.(*github.License).GetSPDXID(), "LGPL-3.0")
}
