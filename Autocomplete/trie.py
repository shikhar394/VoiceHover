"""
A fast data structure for searching strings with autocomplete support.
"""
import sys
from six.moves import cPickle 
import timeit
class Trie(object):
    def __init__(self):
        self.children = {}
        self.flag = False # Flag to represent that a word ends at this node

    def add(self, char):
        self.children[char] = Trie()

    def insert(self, word):
        node = self
        for char in word:
            if char not in node.children:
                node.add(char)
            node = node.children[char]
        node.flag = True

    def contains(self, word):
        node = self
        for char in word:
            if char not in node.children:
                return False
            node = node.children[char]
        return node.flag

    def all_suffixes(self, prefix):
        results = set()
        if self.flag:
            results.add(prefix)
        if not self.children: return results
        return reduce(lambda a, b: a | b, [node.all_suffixes(prefix + char) for (char, node) in self.children.items()]) | results

    def autocomplete(self, prefix):
        node = self
        for char in prefix:
            if char not in node.children:
                return set()
            node = node.children[char]
        return list(node.all_suffixes(prefix))

if __name__ == '__main__':
    prefix = 'aba'
    Word_Completion = Trie()
    f = open("google-10000-english-usa-no-swears.txt")
    for line in f:
        line = line.strip()
        Word_Completion.insert(line)
    words_begins = Word_Completion.autocomplete(prefix)
    print(sys.getsizeof(Word_Completion))
    print(words_begins)
