using DataStructures,OrderedCollections
using Plots
gr()

book = open("books/francais/flaubert_correspondance_tome_II.txt","r")
text_data = readlines(book)
close(book)
words = []

function isalnum(c::Char)
    return isletter(c) || isdigit(c) || c in [''']
end
# return filter(c -> isalnum(c), w)
function clean_word(w::String)
    return filter(c -> isalnum(c), w)
end
            

# for w in split(lowercase(replace(line, "’" => " ")), ' ')
for line in text_data
    replaced_line = lowercase(replace(line, "’" => " ", "'" => " "))
    for w in split(replaced_line, ' ')
        clean_w = clean_word(String(w))
        if length(clean_w) > 0
            push!(words,clean_w)
        end
    end
end

word_counter = counter(words)
sorted_words = sort(collect(word_counter),by=x->-x[2])

log_ranks = [log(rank) for rank in 1:length(sorted_words)]
log_frequencies = [log(frequence[2]) for frequence in sorted_words]

long_moy_word = sum([length(w) for w in words])/length(words)

println(long_moy_word)



