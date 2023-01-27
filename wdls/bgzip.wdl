version 1.0

task bgzip_ {
	input {
		File vcf
	}
	
	command <<<
		bgzip -k ~{vcf}
		mv ~{vcf}.gz $(basename ~{vcf}.gz)
	>>>

	output {
		File zipped_vcf = basename("${vcf}.gz")
	}

	runtime {
		docker: "developmentontheedge/vcftools:v0.0.2"
	}
}


workflow bgzip {
	input {
		File vcf
	}

	call bgzip_ {
		input:
		vcf = vcf
	}

	output {
		File vcf_gz = bgzip_.zipped_vcf
	}
}
