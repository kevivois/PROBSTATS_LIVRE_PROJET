using DataStructures,OrderedCollections
using Plots

include("PCA.jl")


function isalnum(c::Char)
    return isletter(c) || isdigit(c) || c in [''']
end

function clean_word(w::String)
    return filter(c -> isalnum(c) || c == ' ', w)
end

function get_words(text_data::Vector{String})::Vector{String}
    res::Vector{String} = []

    for line in text_data
        replaced_line = lowercase(replace(line, "’" => " ", "'" => " "))
        for w in split(replaced_line, ' ')
            clean_w = clean_word(String(w))
            if length(clean_w) > 0
                push!(res,clean_w)
            end
        end
    end
    return res
end

function get_sentences(text_data::Vector{String})::Vector{String}
    res::Vector{String} = []

    for line in text_data
        replaced_line = lowercase(replace(line, "’" => " ", "'" => " "))
        for sentence in split(replaced_line, r"[.!?]")
            clean_sentence = strip(clean_word(String(sentence)))
            if length(clean_sentence) > 0
                push!(res,clean_sentence)
            end
        end
    end
    return res
end

function num_letters(text_data::Vector{String})::Integer
    res::Integer = 0
    
    for line in text_data
        replaced_line = lowercase(replace(line, "’" => " ", "'" => " "))
        for char in replaced_line
            if isletter(char)
                res += 1
            end
        end
    end
    return res
end

function letter_frequency(text_data::Vector{String})::Dict{Char, Float64}
    freq::Dict{Char, Int} = Dict{Char, Int}()
    total_letters = num_letters(text_data)
    
    for line in text_data
        replaced_line = lowercase(replace(line, "’" => " ", "'" => " "))
        for char in replaced_line
            if isletter(char)
                if haskey(freq, char)
                    freq[char] += 1
                else
                    freq[char] = 1
                end
            end
        end
    end

    freq_percent::Dict{Char, Float64} = Dict{Char, Float64}()
    for (char, count) in freq
        freq_percent[char] = (count / total_letters)
    end
    
    return freq_percent
end

languages::Vector{String} = ["allemand", "anglais", "francais"]
book_infos::Dict = Dict()
book_word_info::Dict = Dict()

mean_length_words_arr = []
mean_number_words_sentences_arr = []
letter_frequency_percent_arr = []

for l in languages
    folder_path = "books/$l"
    txt_files = filter(f -> endswith(f, ".txt"), readdir(folder_path))
    book_words::Dict = Dict()
    book_word_info[l] = []

    for file in txt_files
        println("$folder_path/$file")
        book::IOStream = open("$folder_path/$file","r")
        text_data = readlines(book)
        close(book)

        words = get_words(text_data)
        sentences = get_sentences(text_data)
        letter_freq  = letter_frequency(text_data)
        push!(book_word_info[l], Dict(file => Dict("words_num" => length(words), "different_word" => length(Set(words)))))
        println(length(Set(words))) # nbre de mot différents / nombre de mots

        number_of_letters_tot = sum([length(w) for w in words])
        mean_length_words_book::Float64 = sum([length(w) for w in words])/length(words)
        mean_words_in_sentences::Float64 = sum([length(split(w, " ")) for w in sentences])/length(sentences)

        
        infos = Dict(
            "mean_length_words" => mean_length_words_book,
            "mean_number_words_sentences" => mean_words_in_sentences,
            "letter_frequency_percent" => letter_freq
        )
        push!(mean_length_words_arr,mean_length_words_book)
        push!(mean_number_words_sentences_arr,mean_words_in_sentences)
        push!(letter_frequency_percent_arr,letter_freq)
        book_words[file] = infos
    end
    book_infos[l] = book_words
end

function display_graph_with_average(book_word_info)
    global_books = []
    global_unique_words = []
    book_colors = []  # Liste des couleurs pour les livres (chaque couleur pour chaque langue)
    language_legends = Dict()  # Associe chaque couleur à une langue pour la légende

    # Définir une palette de couleurs pour les barres des livres
    color_palette = [:yellow, :green, :red, :purple, :orange, :cyan, :magenta, :blue, :brown, :gray]

    # Attribuer une couleur unique à chaque langue pour le graphique global
    lang_colors = Dict()
    languages = keys(book_word_info)

    # Assigner une couleur unique à chaque langue
    for (i, lang) in enumerate(languages)
        lang_colors[lang] = color_palette[(i-1) % length(color_palette) + 1]
        language_legends[lang_colors[lang]] = lang  # Associer la couleur à la langue
    end

    for l in keys(book_word_info)
        # Préparation des données pour chaque langue
        books = []
        unique_words = []
        
        for book_data in book_word_info[l]
            for (file, stats) in book_data
                push!(books, file)  # Nom du livre
                push!(unique_words, stats["different_word"])  # Nombre de mots différents
                # Ajouter aux données globales
                push!(global_books, "[$l] $file")
                push!(global_unique_words, stats["different_word"])
                # Ajouter la couleur associée à la langue pour le graphique global
                push!(book_colors, lang_colors[l])
            end
        end

        # Calcul de la moyenne pour chaque langue
        avg_unique_words = mean(unique_words)
        
        # Tracé des données pour chaque langue
        b = bar(1:length(books), unique_words, label="Unique Words", title="Unique Words per Book ($l)",
            xlabel="Books - $l", ylabel="Number of Unique Words", legend=:top, color=lang_colors[l])

        plot!(1:length(books), fill(avg_unique_words, length(books)), label="Average", color=:black, lw=2)
        
        # Affiche le graphique pour chaque langue
        display(b)
    end

    # Graphique global avec des couleurs différentes pour chaque langue
    if !isempty(global_books)
        # Calcul de la moyenne globale
        global_avg_unique_words = mean(global_unique_words)

        # Tracé des données globales avec des couleurs différentes pour chaque langue
        b_2 = bar(1:length(global_books), global_unique_words, title="Nombre de mots différents pour les livres", label="",
                  xlabel="Livres", xticks=(1:length(global_books), 1:length(global_books)), ylabel="Nombre de mots différents", legend=:topright,
                  color=book_colors)  # Utilisation de book_colors pour chaque barre selon la langue
        
        plot!(1:length(global_books), fill(global_avg_unique_words, length(global_books)), label="Moyenne globale", color=:black, lw=2)
        
        # Trier la légende dans l'ordre d'apparition des couleurs sur le graphique
        ordered_colors = unique(book_colors)  # Ordre d'apparition des couleurs
        for color in ordered_colors
            bar!([0], [0], label=language_legends[color], color=color)
        end

        # Affiche le graphique global
        display(b_2)
    end
end
function display_graph_with_average_ratio(book_word_info)
    global_books = []
    global_unique_words_ratio = []
    book_colors = []  # Liste des couleurs pour les livres (chaque couleur pour chaque langue)
    language_legends = Dict()  # Associe chaque couleur à une langue pour la légende

    # Définir une palette de couleurs pour les barres des livres
    color_palette = [:yellow, :green, :red, :purple, :orange, :cyan, :magenta, :blue, :brown, :gray]

    # Attribuer une couleur unique à chaque langue pour le graphique global
    lang_colors = Dict()
    languages = keys(book_word_info)

    # Assigner une couleur unique à chaque langue
    for (i, lang) in enumerate(languages)
        lang_colors[lang] = color_palette[(i-1) % length(color_palette) + 1]
        language_legends[lang_colors[lang]] = lang  # Associer la couleur à la langue
    end

    for l in keys(book_word_info)
        # Préparation des données pour chaque langue
        books = []
        unique_words_ratio = []
        
        for book_data in book_word_info[l]
            for (file, stats) in book_data
                push!(books, file)  # Nom du livre
                push!(unique_words_ratio, stats["different_word"] / stats["words_num"])  # Ratio des mots uniques
                # Ajouter aux données globales
                push!(global_books, "[$l] $file")
                push!(global_unique_words_ratio, stats["different_word"] / stats["words_num"])
                # Ajouter la couleur associée à la langue pour le graphique global
                push!(book_colors, lang_colors[l])
            end
        end

        # Calcul de la moyenne pour chaque langue
        avg_unique_words_ratio = mean(unique_words_ratio)
        
        # Tracé des données pour chaque langue
        b = bar(1:length(books), unique_words_ratio, label="Unique Words Ratio", title="Unique Words Ratio per Book ($l)",
            xlabel="Books - $l", ylabel="Ratio of Unique Words", legend=:top, color=lang_colors[l])

        plot!(1:length(books), fill(avg_unique_words_ratio, length(books)), label="Average", color=:black, lw=2)
        
        # Affiche le graphique pour chaque langue
        display(b)
    end

    # Graphique global avec des couleurs différentes pour chaque langue
    if !isempty(global_books)
        # Calcul de la moyenne globale
        global_avg_unique_words_ratio = mean(global_unique_words_ratio)

        # Tracé des données globales avec des couleurs différentes pour chaque langue
        b_2 = bar(1:length(global_books), global_unique_words_ratio, title="Ratio de mots différents pour les livres", label="",
                  xlabel="Livres", xticks=(1:length(global_books), 1:length(global_books)), ylabel="Ratio de mots différents", legend=:topright,
                  color=book_colors)  # Utilisation de book_colors pour chaque barre selon la langue
        
        plot!(1:length(global_books), fill(global_avg_unique_words_ratio, length(global_books)), label="Moyenne globale", color=:black, lw=2)
        
        # Trier la légende dans l'ordre d'apparition des couleurs sur le graphique
        ordered_colors = unique(book_colors)  # Ordre d'apparition des couleurs
        for color in ordered_colors
            bar!([0], [0], label=language_legends[color], color=color)
        end

        # Affiche le graphique global
        display(b_2)
    end
end



display_graph_with_average(book_word_info)
display_graph_with_average_ratio(book_word_info)

# Construire la matrice
create_plot_PCA_languages(book_infos)

# Test Zipf
book_test::IOStream = open("books/francais/flaubert_correspondance_tome_II.txt","r")
text_data_test = readlines(book_test)
words = get_words(text_data_test)
word_counter = counter(words)
sorted_words_frequencies = sort(collect(word_counter),by=x->-x[2])

log_ranks = [log(rank) for rank in 1:length(sorted_words_frequencies)]
log_frequencies = [log(frequence[2]) for frequence in sorted_words_frequencies]

Plots.plot(log_ranks, log_frequencies, label=false, title="loi de Zipf Flaubert",
    xaxis = "log rank", yaxis = "log frequency")
