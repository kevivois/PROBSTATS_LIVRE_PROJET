using Plots
using MultivariateStats, StatsBase, LinearAlgebra
gr()


function create_plot_PCA_languages(book_infos)
    dimension_names = vcat(["mean_length_words", "mean_number_words_sentences"], [string(c) for c in 'a':'z'])
    matrix_transposed = build_data_matrix(book_infos)'
    matrix_centered_normalized = StatsBase.transform(StatsBase.fit(ZScoreTransform, matrix_transposed; dims=2, center=true, scale=true), matrix_transposed)
    model_matrix = MultivariateStats.fit(PCA, matrix_centered_normalized; maxoutdim=2)
    eigenvectors = LinearAlgebra.eigvecs(model_matrix)

    # Calcul des contributions absolues
    contributions_abs = abs.(eigenvectors)

    # Normalisation pour obtenir les pourcentages
    contributions_pc1 = contributions_abs[:, 1] ./ sum(contributions_abs[:, 1]) * 100
    contributions_pc2 = contributions_abs[:, 2] ./ sum(contributions_abs[:, 2]) * 100

    # Affichage des résultats
    println("Pourcentages de contribution pour PC1 :")
    for (name, percentage) in zip(dimension_names, contributions_pc1)
        percentage = round(percentage, digits=2)
        println("$name : $percentage%")
    end

    println("\nPourcentages de contribution pour PC2 :")
    for (name, percentage) in zip(dimension_names, contributions_pc2)
        percentage = round(percentage, digits=2)
        println("$name : $percentage%")
    end

    matrix_PCA = MultivariateStats.transform(model_matrix, matrix_centered_normalized)
    PCA1_matrix = matrix_PCA[1,:]
    PCA2_matrix = matrix_PCA[2,:]

    b = Plots.scatter(PCA1_matrix, PCA2_matrix, groups=get_categories(book_infos),
        legend=true, title="Affichage des données après PCA", xlabel="PCA 1", ylabel="PCA 2")
    display(b)
end

function get_categories(book_infos)
    res = []
    for (languages, books) in book_infos
        for (_, _) in books
            push!(res, languages)
        end
    end
    return res
end

function build_data_matrix(book_infos::Dict)::Matrix{Float64}
    #TODO Changer 28
    res = Matrix{Float64}(undef,0,28)
    row = []

    for (_, books) in book_infos
        for (_, metrics) in books
            mean_length_words = metrics["mean_length_words"]
            mean_number_words_sentences = metrics["mean_number_words_sentences"]
            row = [mean_length_words, mean_number_words_sentences]

            letter_freq = metrics["letter_frequency_percent"]
            for c in 'a':'z'
                if c in keys(letter_freq)
                    push!(row,letter_freq[c])
                else
                    push!(row, 0)
                end
            end
            res = vcat(res,reshape(row, 1, :))
        end
    end
    return res
end
