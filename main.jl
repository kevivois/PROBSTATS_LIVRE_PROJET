using DataStructures

book = open("books/flaubert_correspondance_tome_II.txt","r")
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

c = counter(words)
println(c)
