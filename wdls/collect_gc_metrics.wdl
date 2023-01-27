version 1.0

task collect_gc_metrics_ {
	input {
		File bam
		File ref_fasta
		String gc_bias_metrics_txt = "gc_bias_metrics.txt"
		String summary_metrics_txt = "summary_metrics.txt"
		String chart_pdf = "gc_bias_metrics.pdf"
	}

	command <<<
		java -jar /home/picard/build/libs/picard.jar CollectGcBiasMetrics \
		-I ~{bam} \
		-R ~{ref_fasta} \
		-O ~{gc_bias_metrics_txt} \
		-S ~{summary_metrics_txt} \
		-CHART ~{chart_pdf}
	>>>

	output {
		File out_chart_pdf = "${chart_pdf}"
	}

	runtime {
		docker: "developmentontheedge/picard:0.2"
	}
}

workflow collect_gc_metrics {
	input {
		File bam
		File ref_fasta
		String? gc_bias_metrics_txt
		String? summary_metrics_txt
		String? chart_pdf
	}

	call collect_gc_metrics_ {
		input:
		bam = bam,
		ref_fasta = ref_fasta,
		gc_bias_metrics_txt = gc_bias_metrics_txt,
		summary_metrics_txt = summary_metrics_txt,
		chart_pdf = chart_pdf
	}

	output {
		File out_chart_pdf = collect_gc_metrics_.out_chart_pdf
	}
}
