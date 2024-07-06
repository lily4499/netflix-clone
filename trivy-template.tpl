{
  "Results": [
    {{- range . }}
    {
      "Target": "{{ .Target }}",
      "Vulnerabilities": [
        {{- range .Vulnerabilities }}
        {
          "VulnerabilityID": "{{ .VulnerabilityID }}",
          "PkgName": "{{ .PkgName }}",
          "InstalledVersion": "{{ .InstalledVersion }}",
          "FixedVersion": "{{ .FixedVersion }}",
          "Severity": "{{ .Severity }}",
          "Title": "{{ .Title }}"
        }
        {{- end }}
      ]
    }
    {{- end }}
  ]
}
