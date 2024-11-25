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

languages::Vector{String} = ["deutsch", "english", "french"]
book_infos::Dict = Dict()

mean_length_words_arr = []
mean_number_words_sentences_arr = []
letter_frequency_percent_arr = []
for l in languages
    folder_path = "books/$l"
    txt_files = filter(f -> endswith(f, ".txt"), readdir(folder_path))
    book_words::Dict = Dict()
    for file in txt_files
        println("$folder_path/$file")
        book::IOStream = open("$folder_path/$file","r")
        text_data = readlines(book)
        close(book)

        words = get_words(text_data)
        sentences = get_sentences(text_data)
        letter_freq  = letter_frequency(text_data)

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

# Construire la matrice
create_plot_PCA_languages(book_infos)

# Test Zipf
book_test::IOStream = open("books/french/flaubert_correspondance_tome_II.txt","r")
text_data_test = readlines(book_test)
words = get_words(text_data_test)
word_counter = counter(words)
sorted_words_frequencies = sort(collect(word_counter),by=x->-x[2])

log_ranks = [log(rank) for rank in 1:length(sorted_words_frequencies)]
log_frequencies = [log(frequence[2]) for frequence in sorted_words_frequencies]

Plots.plot(log_ranks, log_frequencies, label=false, title="loi de Zipf Flaubert",
    xaxis = "log rank", yaxis = "log frequency")
