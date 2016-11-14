import std.stdio : File, writeln;
import std.uni : toLowerInPlace;
import std.conv : to;
import std.experimental.allocator: theAllocator, allocatorObject, makeArray, dispose;
import std.experimental.allocator.mallocator : Mallocator;
import std.string : lineSplitter;
// import std.datetime;

import containers.dynamicarray : DynamicArray;

void main(string[] args)
{
	if(!checkArgs(args)) {
		writeln("Usage: ", args[0], " <alphabet> <number of characters (equal or less to alphabet size)>");
		return;
	}
	Mallocator malloc;
	theAllocator = allocatorObject(malloc);

	File f = File("words.txt");
	char[] buffer = makeArray!(char)(theAllocator, cast(size_t) f.size);
	scope(exit) dispose(theAllocator, buffer);
	f.rawRead(buffer);

	DynamicArray!(char[], Mallocator, false) words;

	foreach(char[] word; buffer.lineSplitter()) {
		word.toLowerInPlace();
		words ~= word;
	}

	char[] letters = makeArray!char(theAllocator, args[1].length);
	scope(exit) dispose(theAllocator, letters);
	letters[] = args[1];
	letters.toLowerInPlace;

	writeln("Solutions:");
	foreach(result; solveOtherWayAround(words, letters, to!uint(args[2]))) writeln(result);

	// uint repeats = args.length > 3 ? to!uint(args[3]) : 1_000;
	// auto benchResult = benchmark!({solveOtherWayAround(words, args[1], to!uint(args[2]));})(repeats);
	// writeln("time: ", to!Duration(benchResult[0]));
}

private auto solveOtherWayAround(R)(ref R words, const(char)[] letters, uint size) {
	ubyte[256] masterTable;
	foreach(ubyte b; letters) masterTable[b]++;
	ubyte[256] tempTable = void;

	DynamicArray!(char[], Mallocator, false) results;

loop1:
	foreach(word; words) {
		if(word.length != size) continue;
		tempTable = masterTable;
		foreach(ubyte c; word) {
			if(!tempTable[c]) continue loop1;
			tempTable[c]--;
		}
		results ~= word;
	}

	return results;
}

private bool checkArgs(string[] args) {
	if(args.length < 3) return false;
	try {
		uint size = to!uint(args[2]);
		return args[1].length >= size;
	} catch (Exception e) {
		return false;
	}
}
/*
private char[][] solveCombinatoricPermutations(T)(ref T aa, const(char)[] letters, uint size) {
	import mir.combinatorics;
	import containers.internal.hash;
	import containers.hashset;
	char[] input = makeArray!char(theAllocator, letters.length);
	scope(exit) dispose(theAllocator, input);
	input[] = letters;
	input.toLowerInPlace();
	
	auto combis = combinations(cast(ubyte[]) input, size);
	
	char[] output = makeArray!char(theAllocator, size);
	scope(exit) dispose(theAllocator, output);
	
	HashSet!(char[],Mallocator, generateHash!(char[]), false) results;
	
	foreach(combi;combis) {
		auto rp = makePermutations(theAllocator, size);
		scope(exit) dispose(theAllocator, rp);
		auto perms = indexedRoR(rp, combi);
		foreach(perm; perms) {
			size_t j = 0;
			foreach(c; perm) output[j++] = c;
			if(auto p = output in aa) {
				results.put(*p);
			}
		}
	}

	char[][] retVal = theAllocator.makeArray!(char[])(results.length);
	size_t i = 0;
	foreach(key; results.range()) retVal[i++] = key;

	return retVal;
}
*/