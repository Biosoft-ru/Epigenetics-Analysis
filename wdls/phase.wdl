version 1.0

task phase_ {
	input {
		File ref_fasta
		File ref_fasta_fai
		File bam
		File bam_bai
		File vcf
	}

	command <<<
		source activate whp
		ln -s ~{ref_fasta_fai} "~{ref_fasta}.fai"
		whatshap phase -o phased.vcf \
		--reference ~{ref_fasta} ~{vcf} ~{bam}
	>>>

	output {
		File phased_vcf = "phased.vcf"
	}

	runtime {
		docker: "developmentontheedge/whatshap:latest"
	}
}

workflow phase {
	input {
		File ref_fasta
		File ref_fasta_fai
		File bam
		File bam_bai
		File vcf
	}

	call phase_ {
		input:
		ref_fasta=ref_fasta,
		ref_fasta_fai=ref_fasta_fai,
		bam=bam,
		bam_bai=bam_bai,
		vcf=vcf
	}

	output {
		File phased_vcf = phase_.phased_vcf
	}
}
