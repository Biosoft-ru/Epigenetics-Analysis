version 1.0

task haplotag_ {
	input {
		File ref_fasta
		File ref_fasta_fai
		File vcf_gz
		File vcf_gz_tbi
		File bam
		File bam_bai
	}

	command <<<
		source activate whp
		ln -s ~{bam_bai} "~{bam}.bai"
		ln -s ~{ref_fasta_fai} "~{ref_fasta}.fai"
		ln -s ~{vcf_gz_tbi} "~{vcf_gz}.tbi"
		whatshap haplotag -o haplotagged.bam \
		--reference ~{ref_fasta} ~{vcf_gz} ~{bam}
	>>>

	output {
		File haplotagged_bam = "haplotagged.bam"
	}

	runtime {
		docker: "developmentontheedge/whatshap:latest"
	}
}

workflow haplotag {
	input {
		File ref_fasta
		File ref_fasta_fai
		File vcf_gz
		File vcf_gz_tbi
		File bam
		File bam_bai
	}

	call haplotag_ {
		input:
		ref_fasta=ref_fasta,
		ref_fasta_fai=ref_fasta_fai,
		vcf_gz=vcf_gz,
		vcf_gz_tbi=vcf_gz_tbi,
		bam=bam,
		bam_bai=bam_bai
	}

	output {
		File haplotagged_bam = haplotag_.haplotagged_bam
	}

}
