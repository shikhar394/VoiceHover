import pygtrie as trie
from msvcrt import getch

Trie = trie.CharTrie()

Trie['cat'] = True
Trie['caterpillar'] = True
    

print 'Start typing a word, "exit" to stop'
print '(Other words you might want to try: %s)' % ', '.join(sorted(
    k for k in Trie if k != 'exit'))

text = ''
while True:
    ch = getch()
    if ord(ch) < 32:
        print 'Exiting'
        break

    text += ch
    value = Trie.get(text)
    if value is False:
        print 'Exiting'
        break
    if value is not None:
        print repr(text), 'is a word'
    if Trie.has_subtrie(text):
        print repr(text), 'is a prefix of a word'
    else:
        print repr(text), 'is not a prefix, going back to empty string'
        text = ''
 

