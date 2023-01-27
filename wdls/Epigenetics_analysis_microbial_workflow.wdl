version 1.0

import "samtools_faidx.wdl" as samtools_faidx
import "samtools_index.wdl" as samtools_index
import "pbmm2_1.wdl" as pbmm2
import "bgzip.wdl" as bgzip
import "tabix.wdl" as tabix
import "primrose.wdl" as primrose
import "pb_cpg_tools_microbial.wdl" as pb_cpg_tools

workflow epigenetics_analysis_microbial {
	input {
		File ref_fasta
		File bam
	}

	call samtools_faidx.call_samtools_faidx as faidx {
		input:
		reference_fasta = ref_fasta
	}

	File ref_fasta_fai = faidx.fai

	call pbmm2.run_pbmm2 as align {
		input:
		sample_name = "a",
		reference_name = "hg38",
		reference_fasta = ref_fasta,
		reference_index = ref_fasta_fai,
		movies = [bam]
	}

	Array[File] bams = align.bams
	Array[File] bais = align.bais

	File aligned_bam = bams[0]
	File aligned_bam_bai = bais[0]

	call primrose.primrose as primrose_ {
		input:
		bam = aligned_bam,
		bam_bai = aligned_bam_bai
	}

	File primrose_bam = primrose_.primrose_bam

	call samtools_index.index as index {
		input:
		bam = primrose_bam
	}

	File primrose_bam_bai = index.bam_bai

	call pb_cpg_tools.pb_cpg_tools as pb_cpg_tools {
		input:
		ref_fasta = ref_fasta,
		bam = primrose_bam,
		bam_bai = primrose_bam_bai
	}

	output {
		File combined_bed = pb_cpg_tools.combined_bed
		File combined_bw = pb_cpg_tools.combined_bw
		File out_bam = primrose_.primrose_bam
	}
}
