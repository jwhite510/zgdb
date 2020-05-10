
if exists('g:autoloaded_zgdb')
  finish
endif

let g:autoloaded_zgdb = 1

function! zgdb#start()

	" get current file position for break point
	let s:currentfile=expand("%:t")
	let s:currentfileline=line(".")

	" search recursively backward for a .gdb file
	" get current file directory
	let s:searchdir=expand('%:p:h')
	let s:startsearchdir=expand('%:p:h')
	" search upward for a debug.gdb file
	let s:foundgdbfile=0
	let s:gdbfile=""
	while 1

		let s:pathfiles=split(globpath(s:searchdir, '*'),'\n')
		" echo "searching:"
		" echo s:searchdir
		for i in s:pathfiles
			" echo i
			" echo fnamemodify(i,"")
			if fnamemodify(i,":t") == "debug.gdb"
				let s:gdbfile=i
				" echo "FOUND debug.gdb file"
				let s:foundgdbfile=1
				break
			endif
		endfor

		if s:searchdir != $HOME
			let s:searchdir=fnamemodify(s:searchdir, ":h")
		endif

		if s:searchdir==$HOME
			break
		endif

	endwhile

	if s:foundgdbfile
		" echo "found gdb file"
		" echo s:gdbfile
		" echo fnamemodify(s:gdbfile, ":h")

		" create terminal
		execute 'new'

		let s:cmdstring1="gdb -q -x debug.gdb"
		let s:cmdstring2 = " -ex 'break ".s:currentfile.":".s:currentfileline."'"." -ex 'r'"
		let s:cmdstring3 = " -ex refresh"

		let s:jobid=termopen(s:cmdstring1.s:cmdstring2.s:cmdstring3, {'cwd':fnamemodify(s:gdbfile, ":h")} )
		" +gdb -q -x debug.gdb -ex 'break zernikedatagen.h:296' -ex 'r'


	else
		" create a default gdb file here
		execute 'new'
		let s:defaultdebugfile=["## script will execute by GDB",
					\ "# cd the/build/directory/starting/from/this/file/directory",
					\ "# file a.out"]
		call writefile(s:defaultdebugfile, s:startsearchdir."/debug.gdb", "a")

		execute 'e '.s:startsearchdir.'/debug.gdb'

		" echo "could not find gdbfile"
		" echo "creating default gdb file in start dir"
		" execute "silent !touch ./.grepignorefile > /dev/null 2>&1"
	endif


endfunction
