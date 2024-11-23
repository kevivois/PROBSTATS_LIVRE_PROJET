using Plots

# key words pour chaque genre
keywords_by_genre = Dict(
    "romance" => Dict(
        "amour" => 0.3, "passion" => 0.2, "cœur" => 0.2, "romantique" => 0.15,
        "désir" => 0.15, "baiser" => 0.1, "tendresse" => 0.1, "romance" => 0.1,
        "sentiment" => 0.1, "flamme" => 0.1, "jalousie" => 0.1, "caresse" => 0.1,
        "fiancé" => 0.1, "mariage" => 0.1, "séduction" => 0.1, "tristesse" => 0.05,
        "émois" => 0.05, "coup de foudre" => 0.05, "romanesque" => 0.05
    ),
    "policier" => Dict(
        "crime" => 0.3, "meurtre" => 0.25, "enquête" => 0.2, "suspect" => 0.15,
        "indices" => 0.15, "police" => 0.1, "inspecteur" => 0.1, "preuve" => 0.1,
        "criminel" => 0.1, "coupable" => 0.1, "alibi" => 0.1, "mystère" => 0.1,
        "victime" => 0.1, "piste" => 0.1, "justice" => 0.1, "prison" => 0.05,
        "mobile" => 0.05, "détective" => 0.05, "arrestation" => 0.05, "interrogatoire" => 0.05
    ),
    "science-fiction" => Dict(
        "espace" => 0.3, "robot" => 0.2, "galaxie" => 0.2, "futur" => 0.15,
        "technologie" => 0.15, "intelligence" => 0.1, "cyborg" => 0.1, "univers" => 0.1,
        "vaisseau" => 0.1, "extraterrestre" => 0.1, "temps" => 0.1, "planète" => 0.1,
        "colonisation" => 0.1, "paradoxe" => 0.1, "dimension" => 0.1, "énergie" => 0.05,
        "système" => 0.05, "scientifique" => 0.05, "technologique" => 0.05, "hyperspace" => 0.05
    ),
    "fantasy" => Dict(
        "dragon" => 0.3, "magie" => 0.2, "royaume" => 0.2, "quête" => 0.15,
        "épée" => 0.15, "sorcier" => 0.1, "elfe" => 0.1, "sortilège" => 0.1,
        "chevalier" => 0.1, "château" => 0.1, "malédiction" => 0.1, "créature" => 0.1,
        "gobelin" => 0.1, "prince" => 0.1, "prophétie" => 0.1, "artefact" => 0.05,
        "guerrier" => 0.05, "bataille" => 0.05, "ombre" => 0.05, "démons" => 0.05
    ),
    "horreur" => Dict(
        "terreur" => 0.3, "peur" => 0.25, "sang" => 0.2, "monstre" => 0.15,
        "fantôme" => 0.15, "sombre" => 0.1, "cri" => 0.1, "démon" => 0.1,
        "hurlement" => 0.1, "cadavre" => 0.1, "survivant" => 0.1, "possession" => 0.1,
        "folie" => 0.1, "angoisse" => 0.1, "abomination" => 0.1, "maudit" => 0.1,
        "tueur" => 0.1, "meurtre" => 0.1, "maison hantée" => 0.05, "horreur" => 0.05
    )
)


# check if a character is a letter
function isalnum(c::Char)::Bool
    return isletter(c) || isdigit(c)
end

# clean a word
function clean_word(w::String)::String
    return filter(c -> isalnum(c) || c == ' ', w)
end

# get the words from a text
function get_words(text_data::Vector{String})::Vector{String}
    res::Vector{String} = []
    for line in text_data
        replaced_line = lowercase(replace(line, r"[^\w\s]" => " "))
        for w in split(replaced_line, ' ')
            clean_w = clean_word(String(w))
            if length(clean_w) > 0
                push!(res, clean_w)
            end
        end
    end
    return res
end

# get sentences from a text
function load_book_words(filepath::String)::Vector{String}
    book = open(filepath, "r")
    text_data = readlines(book)
    close(book)
    println("Premières lignes du fichier : ", text_data[1:min(5, length(text_data))])  # Affiche les premières lignes
    return get_words(text_data)
end


# calculate the likelihood of a set of words given a set of keywords
function calculate_likelihood(words::Vector{String}, keywords::Dict{String, Float64})::Float64
    likelihood = 1.0
    for word in words
        likelihood *= get(keywords, word, 1e-6)  # default value is 1e-6 if word not found
    end
    return likelihood
end

# calculate the probabilities of each genre given a set of words
function calculate_genre_probabilities(words::Vector{String}, keywords_by_genre::Dict, genre_priors::Dict)::Dict
    probabilities = Dict{String, Float64}()
    for (genre, keywords) in keywords_by_genre
        prior = genre_priors[genre]
        likelihood = calculate_likelihood(words, keywords)
        probabilities[genre] = prior * likelihood
    end
    # check if total probability is zero
    total = sum(values(probabilities))
    if total == 0
        println("Erreur : Total des probabilités égale à 0. Vérifiez les mots-clés ou les données du livre.")
        return Dict()  # return an empty dictionary in case of error
    end
    # normalize probabilities
    for genre in keys(probabilities)
        probabilities[genre] /= total
    end
    return probabilities
end


# function to get the probabilities of each genre for a given book
function get_genre_probabilities(filepath::String, keywords_by_genre::Dict, genre_priors::Dict)::Dict
    words = load_book_words(filepath)
    println("Mots extraits du livre : ", words[1:min(10, length(words))])  # Affiche les 10 premiers mots
    probabilities = calculate_genre_probabilities(words, keywords_by_genre, genre_priors)
    return probabilities
end


# book path
filepath = "books/french/test.txt"


probabilities = get_genre_probabilities(filepath, keywords_by_genre, genre_priors)

# print the probabilities
println("Probabilités des genres pour le livre :")
for (genre, prob) in probabilities
    println("Genre: $genre, Probabilité: $(round(prob * 100, digits=2))%")
end

# convert the probabilities to a format that can be plotted
genres = collect(keys(probabilities))  
probas = [round(prob * 100, digits=2) for prob in values(probabilities)]  

# bar graph
Plots.bar(genres, probas, legend=false, xlabel="Genres", ylabel="Probabilité (%)", title="Probabilités des genres")
