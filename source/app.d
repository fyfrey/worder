import std.stdio : File, writeln;
import std.uni : toLowerInPlace;
import std.conv : to;
import std.experimental.allocator: theAllocator, allocatorObject, makeArray, dispose;
import std.experimental.allocator.mallocator : Mallocator;
import std.string : lineSplitter;

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

	char[] letters = makeArray!char(theAllocator, args[1].length);
	scope(exit) dispose(theAllocator, letters);
	letters[] = args[1];
	letters.toLowerInPlace;

	writeln("Solutions:");
	foreach (result; solveWord(words, letters, to!uint(args[2]))) writeln(result);
	
	return 0;
}

private auto solveWord(R)(ref R words, const(char)[] letters, uint size)
{
	ubyte[256] masterTable;
	foreach(ubyte b; letters) masterTable[b]++;
	ubyte[256] tempTable = void;

	DynamicArray!(char[], Mallocator, false) results;

	loop1: foreach (word; words)
	{
		if (word.length != size) continue;
		tempTable = masterTable;
		foreach(ubyte c; word)
		{
			if (!tempTable[c]) continue loop1;
			tempTable[c]--;
		}
		results ~= word;
	}

	return results;
}

private bool checkArgs(string[] args)
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
