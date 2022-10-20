process COLLAPSE_DUPLICATES {
    tag 'all_bulk_reps'

    label 'process_long'
    cache  'lenient'
    label 'enchantr'


    conda (params.enable_conda ? "bioconda::r-enchantr=0.0.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/r-enchantr:0.0.1--r41hdfd78af_0':
        'quay.io/biocontainers/r-enchantr:0.0.1--r41hdfd78af_0' }"

    input:
    path(tabs) // tuple [val(meta), sequence tsv in AIRR format ]

    output:
    path("*collapse-pass.tsv"), emit: tab // sequence tsv in AIRR format
    path("*_command_log.txt"), emit: logs //process logs
    path "*_report"
    path "versions.yml" , emit: versions

    script:
    """
    echo "${tabs.join('\n')}" > tabs.txt
    Rscript -e "enchantr::enchantr_report('collapse_duplicates', \\
        report_params=list('input'='tabs.txt',\\
        'collapseby'='${params.collapseby}',\\
        'outdir'=getwd(),\\
        'nproc'=${task.cpus},\\
        'outname'='all_reps',\\
        'log'='all_reps_collapse_command_log'))"

    echo "${task.process}": > versions.yml
    Rscript -e "cat(paste0('  enchantr: ',packageVersion('enchantr'),'\n'))" >> versions.yml

    mv enchantr all_reps_collapse_report
    """
}
