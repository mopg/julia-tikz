struct tikzObj

    flname::String

    lw::Float64                  # default line width
    linecolor::Vector{Float64}   # default line color
    axcolor::Vector{Float64}     # axis color

    standalone::Bool
    smooth::Bool

    fID::IOStream

end

function tikzObj( flname::String;
                  lw = 0.75,
                  linecolor = [0., 0., 0.],
                  axcolor = [0.1, 0.1, 0.1],
                  smooth = false,
                  standalone = false,
                  scale = 1.0,
                  colors=Dict{String,Vector{Float64}}(),
                  styles=Vector{tikzStyle}( 0 ),
                  textheight=12,
                  additional_packages::Vector{String} = Vector{String}(undef,0),
                  additional_packages_with_options::Vector{Tuple{String,String}} = Vector{Tuple{String,String}}(undef,0) )

    fID = open( flname, "w" )

    if standalone
        @printf( fID, "\\documentclass[%dpt]{standalone}\n", textheight )
        # Signature
        @printf( fID, "%% Generated using Tikz.jl on %s, %s\n\n", Dates.today(), Dates.format(Dates.now(), "HH:MM")  )

        # Packages
        @printf( fID, "\\usepackage{tikz,pgfplots}\n" )
        @printf( fID, "\\usepackage{xcolor}\n" )

        for package in additional_packages
            @printf( fID, "\\usepackage{%s}\n", package )
        end

        for package in additional_packages_with_options
            @printf( fID, "\\usepackage[%s]{%s}\n", package[1], package[2] )
        end

        @printf( fID, "\n" )

    end

    # Colors
    @printf( fID, "\\definecolor{defaultc}{RGB}{%3.0f, %3.0f, %3.0f}\n\n", linecolor[1], linecolor[2], linecolor[3] )
    coln = collect(keys(colors))
    for jj in 1:length(colors)
        @printf( fID, "\\definecolor{%s}{RGB}{%3.0f, %3.0f, %3.0f}\n\n",
                 coln[jj], colors[coln[jj]][1], colors[coln[jj]][2], colors[coln[jj]][3] )
    end

    # Styles
    for jj in 1:length(styles)
        #\tikzstyle{my style}=[<tikz options>]
        @printf( fID, "\\tikzstyle{%s}=[", styles[jj].name )
        if styles[jj].lw > 0.0
            @printf( fID, "line width=%3.2fpt, ", styles[jj].lw )
        end
        if length(styles[jj].color) > 0
            @printf( fID, "%s, ", styles[jj].color )
        end
        if styles[jj].linestyle == "--"
            @printf( fID, "dashed, " )
        elseif length(styles[jj].linestyle) > 0
            @printf( fID, "%s, ", styles[jj].linestyle )
        end
        @printf( fID, "%s]\n ", styles[jj].extracommands )
    end
    @printf( fID, "\n" )

    if standalone
        # Start document
        @printf( fID, "\\begin{document}\n\n" )
    end

    @printf( fID, "\\begin{tikzpicture}")
    @printf( fID, "[color=defaultc,line width=%3.2fpt, scale=%3.2f]\n\n", lw, scale )

    return tikzObj( flname, lw, linecolor, axcolor, standalone, smooth, fID )

end

function closeObj( object::tikzObj )

    @printf( object.fID, "\\end{tikzpicture}")

    if object.standalone
        @printf( object.fID, "\n\n\\end{document}")
    end

    close( object.fID )

end
