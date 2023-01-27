version 1.0

import "wdls/samtools_faidx.wdl" as samtools_faidx
import "wdls/samtools_index.wdl" as samtools_index
import "wdls/deepvariant.wdl" as deepvariant
import "wdls/pbmm2.wdl" as pbmm2
import "wdls/bgzip.wdl" as bgzip
import "wdls/tabix.wdl" as tabix
import "wdls/primrose.wdl" as primrose
import "wdls/phase.wdl" as phase
import "wdls/haplotag.wdl" as haplotag
import "wdls/pb_cpg_tools.wdl" as pb_cpg_tools
import "wdls/collect_gc_metrics.wdl" as collect_gc_metrics

workflow epigenetics_analysis {
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

	call deepvariant.call_deepvariant as call_snps {
		input:
		model_type = "PACBIO",
		reference_fasta = ref_fasta,
		reference_index = ref_fasta_fai,
		reads_bam = aligned_bam,
		reads_index = aligned_bam_bai,
		output_vcf_path = "deepvariant_snp.vcf",
		num_shards = 2
	}

	File vcf = call_snps.snp_vcf

	call phase.phase as phase_ {
		input:
		ref_fasta = ref_fasta,
		ref_fasta_fai = ref_fasta_fai,
		bam = aligned_bam,
		bam_bai = aligned_bam_bai,
		vcf = vcf
	}

	File phased_vcf = phase_.phased_vcf

	call bgzip.bgzip as bgzip_ {
		input:
		vcf = phased_vcf
	}

	File vcf_gz = bgzip_.vcf_gz

	call tabix.tabix as tabix_ {
		input:
		vcf_gz = vcf_gz
	}

	File vcf_gz_tbi = tabix_.vcf_gz_tbi

	# UP

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

	call haplotag.haplotag as haplotag_ {
		input:
		ref_fasta = ref_fasta,
		ref_fasta_fai = ref_fasta_fai,
		vcf_gz = vcf_gz,
		vcf_gz_tbi = vcf_gz_tbi,
		bam = primrose_bam,
		bam_bai = primrose_bam_bai
	}

	File haplotagged_bam = haplotag_.haplotagged_bam
	
	call collect_gc_metrics.collect_gc_metrics as collect_gc_metrics_ {
		input:
		bam = haplotagged_bam,
		ref_fasta = ref_fasta
	}

	call samtools_index.index as index1 {
		input:
		bam = haplotagged_bam
	}

	File haplotagged_bam_bai = index1.bam_bai

	call pb_cpg_tools.pb_cpg_tools as pb_cpg_tools {
		input:
		ref_fasta = ref_fasta,
		bam = haplotagged_bam,
		bam_bai = haplotagged_bam_bai
	}

	output {
		File primrose_bam_ = primrose_.primrose_bam
		File snp_vcf = call_snps.snp_vcf
		File html_report = call_snps.html_report
		File combined_bed = pb_cpg_tools.combined_bed
		File combined_bw = pb_cpg_tools.combined_bw
		File hap1_bed = pb_cpg_tools.hap1_bed
		File hap2_bed = pb_cpg_tools.hap2_bed
		File hap1_bw = pb_cpg_tools.hap1_bw
		File hap2_bw = pb_cpg_tools.hap2_bw
		File chart_pdf = collect_gc_metrics_.out_chart_pdf
	}
}
