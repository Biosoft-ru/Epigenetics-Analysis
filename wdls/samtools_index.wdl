version 1.0

task index_ {
	input {
		File bam
	}

	String base_name = basename("${bam}")
	String base_name1 = "${base_name}.bai"

	command <<<
		samtools index ~{bam} -o ~{base_name1}
		echo ~{base_name1} > echo.txt
	>>>

	output {
		File bam_bai = "${base_name1}"
	}

	runtime {
		docker: "developmentontheedge/samtools:latest"
	}
}

workflow index {
	input {
		File bam
	}

	call index_ {
		input:
		bam = bam
	}

	output {
		File bam_bai = index_.bam_bai
	}
}
