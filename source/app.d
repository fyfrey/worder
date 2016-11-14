import std.stdio : File, writeln;
import std.uni : toLowerInPlace;
import std.conv : to;
import std.experimental.allocator: theAllocator, allocatorObject, makeArray, dispose;
import std.experimental.allocator.mallocator : Mallocator;
import std.string : lineSplitter;
import std.algorithm : sort, SwapStrategy;

import containers.dynamicarray : DynamicArray;

int main(string[] args)
{
	if (!checkArgs(args))
	{
		writeln("Usage: ", args[0], " <alphabet> <number of characters (equal or less to alphabet size)>");
		return 1;
	}
	Mallocator malloc;
	theAllocator = allocatorObject(malloc);

	File f = File("words.txt");
	char[] buffer = makeArray!(char)(theAllocator, cast(size_t) f.size);
	scope(exit) dispose(theAllocator, buffer);
	f.rawRead(buffer);

	DynamicArray!(char[], Mallocator, false) words;

	foreach (char[] word; buffer.lineSplitter())
	{
		word.toLowerInPlace();
		words ~= word;
	}

	sort!((a,b) => a.length < b.length, SwapStrategy.stable)(words[]);

	size_t[] indexes = theAllocator.makeArray!size_t(words[$-1].length + 1);
	scope(exit) theAllocator.dispose(indexes);

	indexes[$-1] = words.length;
	size_t l;

	foreach(i, word; words) {
		if(word.length > l) {
			indexes[l] = i;
			l = word.length;
		}
	}

	char[] letters = makeArray!char(theAllocator, args[1].length);
	scope(exit) dispose(theAllocator, letters);
	letters[] = args[1];
	letters.toLowerInPlace;

	writeln("Solutions:");
	uint size = to!uint(args[2]);
	auto slice = words[indexes[size-1]..indexes[size]];
	DynamicArray!(char[], Mallocator, false) results;
	solveWord(slice, letters, results);

	foreach (result; results) writeln(result);

	return 0;
}

private void solveWord(R, O)(ref R words, const(char)[] letters, ref O outputRange) @nogc nothrow
{
	ubyte[256] masterTable;
	foreach(ubyte b; letters) masterTable[b]++;
	ubyte[256] tempTable = void;

	loop1: foreach (word; words)
	{
		tempTable = masterTable;
		foreach(ubyte c; word)
		{
			if (!tempTable[c]) continue loop1;
			tempTable[c]--;
		}
		outputRange ~= word;
	}
}

private bool checkArgs(string[] args) nothrow
{
	if (args.length < 3) return false;
	try
	{
		uint size = to!uint(args[2]);
		return args[1].length >= size;
	}
	catch (Exception e)
	{
		return false;
	}
}
