process getPhredTrimmed {
        container 'ufuomababatunde/samtoolsv1.17--pymodulesv4'

        tag "${sample}"

        publishDir (
        path: "${params.outDir}/${task.process.replaceAll(":","_")}",
        mode: 'copy',
        overwrite: 'true'
        )


        input:
        tuple val(sample), path(fastq)

        output:
        tuple val(sample), path("*.updated.json"), emit: phredJSON

        script:
        """
        median_quality.py \\
            --inFastq ${fastq} \\
            --outSummary ${sample}.summaryQual.tsv
        
        readBP=\$(tail -n+2 ${sample}.summaryQual.tsv | awk -F "\\t" '{print \$1}' | paste -sd ',')

        readPhred=\$(tail -n+2 ${sample}.summaryQual.tsv | awk -F "\\t" '{print \$2}' | paste -sd ',')


        create_blankJSON.py \\
            --title ${params.outDir} \\
            --outJSON starting_blank.json


        update_json.py \\
            --json starting_blank.json \\
            --out ${sample}.updated.json \\
            --sample ${sample} \\
            --feature qc_bp \\
            --value \${readBP}

        update_json.py \\
            --json ${sample}.updated.json \\
            --out ${sample}.updated.json \\
            --sample ${sample} \\
            --feature qc_phred \\
            --value \${readPhred}
        """
}