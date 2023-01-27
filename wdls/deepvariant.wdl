version 1.0
task deepvariant {
	input {
		String model_type
		File reference_fasta
		File reference_index
		File reads_bam
		File reads_index
		String output_vcf_path
		##String? output_gvcf_path
		Int num_shards
	}

	String html_path = sub("${output_vcf_path}", ".vcf", ".visual_report.html")
	
	command {
		echo "${html_path}" > html_path.txt

		cp ${reference_index} ${reference_fasta}.fai
		/opt/deepvariant/bin/run_deepvariant \
		--model_type ${model_type} \
		--ref  ${reference_fasta} \
		--reads ${reads_bam} \
		--output_vcf ${output_vcf_path} \
		--num_shards ${num_shards} 
	}
	

	output {
		File out_vcf= "${output_vcf_path}"
		File html_report = "${html_path}"
		##File "${output_gvcf_path}"
	}

	runtime {
		docker:"developmentontheedge/deepvariant:0.3"
	}
}

workflow call_deepvariant {
	input {
		String model_type
		File reference_fasta
		File reference_index
		File reads_bam
		File reads_index
		String output_vcf_path
		##String output_gvcf_path
		Int num_shards
	}

	call deepvariant {
		input:
		model_type=model_type,
		reference_fasta=reference_fasta,
		reference_index=reference_index,
		reads_bam=reads_bam,
		reads_index=reads_index,
		output_vcf_path=output_vcf_path,
		##output_gvcf_path=output_gvcf_path,
		num_shards=num_shards,
	}
	
	output {
		File snp_vcf = deepvariant.out_vcf
		File html_report = deepvariant.html_report
	}

	meta{
		description:"##calling snp's with deepvariant"
	}	
}
