package main

import (
	"flag"
	"log"

	"encr.dev/pkg/encorebuild/gentypedefs"
)

func main() {
	version := flag.String("version", "", "Encore version")
	input := flag.String("input", "", "Type definition input")
	dtsOutput := flag.String("dts-output", "", "TypeScript declaration output")
	cjsOutput := flag.String("cjs-output", "", "CommonJS wrapper output")
	flag.Parse()

	err := gentypedefs.Generate(gentypedefs.Config{
		ReleaseVersion: *version,
		TypeDefFile:    *input,
		DtsOutputFile:  *dtsOutput,
		CjsOutputFile:  *cjsOutput,
	})
	if err != nil {
		log.Fatal(err)
	}
}
