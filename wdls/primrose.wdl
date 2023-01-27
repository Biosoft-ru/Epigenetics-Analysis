version 1.0

task primrose_ {
	input {
		File bam
		File bam_bai
	}

	command <<<
		primrose ~{bam} primrose.bam
	>>>

	output {
		File primrose_bam = "primrose.bam"
	}

	runtime {
		docker: "developmentontheedge/primrose:0.1"
	}
}

workflow primrose {
	input {
		File bam
		File bam_bai
	}

	call primrose_ {
		input:
		bam=bam,
		bam_bai=bam_bai
	}

	output {
		File primrose_bam = primrose_.primrose_bam
	}
}
