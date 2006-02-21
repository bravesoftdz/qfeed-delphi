Description 

If you're a Delphi or CBuilder developer, you probably have discovered by now that the QFeed developers were very naughty --- they decided to build an extension DLL, which exports classes as such. This basically means that anybody who is not using Visual C++ can't easily access the DLL.

As an alternative, they provided an OCX. It works fine in Delphi, but doesn't quite do everything the same way as the real API, and who wants that extra layer?

Another fellow, Ross Hemingway, wrote a wrapper DLL in Visual C++ to bridge the gap. Another fine effort, but I guess I'm just anal, because I don't like having that extra DLL laying around. Especially since he didn't make his DLL code available. Besides, I like doing stuff that's supposed to be impossible. As I always say, when the going gets tough, the tough write assembler! So, I wrote a Delphi unit that interfaces directly with the Continuum DLL with no need for such middlemen. Presto change-o!


How it works 

Static class methods are really no different than plain old functions and procedures, with one major exception, they have an "invisible" parameter passed to them. C++ calls it "this", while Delphi calls the same thing "Self". Visual C++ by default uses the "thiscall" calling convention, which is just like the stdcall convention except they pass the this pointer in register ECX. So, all the exported class methods are really just normal exported DLL methods with one extra register set up.

Then, the compiler mangles hell out of the function names so it can keep them straight, i.e. what class type they belong to, overloads, etc. This is actually a good thing, because there is a Windows API function called UndecorateSymbolName (available in the ImageHlp unit) which will actually tell you the parameters and return type of the function --- very helpful when trying to figure out an undocumented DLL.

At any rate, the name mangling makes no difference to me, since I just imported using the function ordinals. Slightly risky, since the ordinals can change between DLL versions, but hey, other stuff can too, so we'll have to revisit this unit whenever a new DLL version comes out anyway.

So, I wrote a little assembly language wrapper for each function, which just pushes the explicit parameters in stdcall order and sticks the this pointer into ECX and calls the function. Piece of cake.

You might notice ContinuumClient itself doesn't bother with the this register. That's because its a singleton global, with neither virtual functions nor data members. There's really nothing for this to point to, so the compiler optimizes it out anyway, so why bother poking it in? Of course, this may change in the future, and if so, at that point I'll just stick in the extracted global pointer.

The global pointer as such is unnecessary, but I pulled it out anyway. Its just a little Microsoft Magic going on. You're probably aware how GetProcAddress works, returning a pointer to a function in the DLL. Well, this little global variable export workst the same way, except you're getting a pointer to a to a ContinuumClient object pointer. So, just spoof GetProcAddress into thinking the pointer is actually a function, and you've got it. Just don't try to call it!

Then, of course, I had to represent the sink classes. Basically, these are pure virtual classes with nothing but a vtable. Originally, I represented them as simple records, sort of a binary equivalent to the way Visual C++ would implement the classes in memory, but that proved to be rather off-putting to most Delphi developers, since you have to understand how classes are implemented and at least a rudimentary amount of assembly language to implement them. You also would need to understand calling conventions in detail. Most people like Delphi precisely because they *don't* have to understand all that crap. I like it because you don't, but if you do, you can exploit that power, unlike certain other environments with the initials VB. Anyway, if you're interested, at the time this was written, details on the way Visual C++ lays out its class structure can be found at:

http://msdn.microsoft.com/library/techart/jangrayhood.htm

Calling convention information is available in the Object Pascal Language Guide or online help.

Now, however, I've submerged all the nasty details into actual classes, more or less identical to the sink classes described in the QFeed documentation.  Just like the native sink classes, they are provided with pure virtual methods which need to be overridden. I decided to name everything identically to the C++ versions, so you can literally use them in the very same way as you would if you were lowering your standards enough to use Visual C++. Just follow the QFeed instructions.


This should be enough for you to browse through the Pascal code and understand what's going on.


I've also provided a little utility unit for common conversions, such as ETime to TDateTime, formatting raw prices, etc.

BTW, this is for all you CBuilder users as well. As you probably know, CBuilder understands Pascal and DCUs, so have at it.
