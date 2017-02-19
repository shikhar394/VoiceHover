from six.moves import cPickle 

f = open("Trie.dat", 'rb')
loaded_obj = cPickle.load(f)
f.close()

def autocomplete_suggest(ch):
    return loaded_obj.autocomplete(ch)
  
for i in 'abcd':
    predicted = autocomplete_suggest(i)
    print(predicted[:10])