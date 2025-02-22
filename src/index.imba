import './util/layout'
import './util/shortcuts'
import './styles'

import './components/app-document'
import './components/app-menu'
import './components/app-code'
import './components/doc-widgets'
import './components/app-search'
import './components/home-page'

import './repl/index'

import {fs,files,ls} from './store'
import * as sw from './sw/controller'

global.flags = document.documentElement.flags

global.debug = yes if document.location.hash.indexOf('debug') >= 0

tag app-root
	prop doc
	prop show-menu

	def setup
		global.site = self
		yes

	def mount
		await sw.load!
		return
	
	get page
		ls(document.location.pathname) or ls('/language/introduction')

	def runCodeBlock data
		if data.example
			router.go(data.example.path)
		elif data.code	
			let file = ls('/examples/apps/playground/app.imba')
			let code = data.code.replace(/^(?=\<\w)/gm,'imba.mount do ')
			code = code.replace(/^# ---\n/gm,'')
			file.overwrite code
			router.go(file.path)

	css $menu
		pt:$header-height
		h:100vh w:$menu-width t:0 pos:fixed
		fs:sm fw:500
		bg:white
		zi:150
		max-width:80vw
		x:-100% @md:0 @focin:0
		border-right:gray3 @md:none
		transition:all 250ms cubic-in-out
	
	css $repl
		of:hidden inset:0 pos:fixed zi:2000 rd:0 bxs:xl
		transition:transform 250ms quint-out
		y:110% .routed:0

	css .open-ide-button
		bottom:0 right:0 m:5 border:gray2 py:3 px:4 rd:3
		cursor:pointer bg:teal5 c:white fw:bold border:teal8/20 bxs:md
		tween:150ms ease-out
		pos:fixed d:block @not-md:none
		@hover y:-2px bxs:lg bg:teal5
		@after o:0.7 fs:xs content: " " $shortcut

	def go path
		self.path = path
		doc ||= ls('/language/introduction')

		let parts = path.replace(/(^\/|\/$)/,'').split('/')
		# redirect home somehow?
		if path == '/' or path == '/index.html'
			doc = ls('/language/introduction')
		elif !path.match(/^\/(home|try)/)
			doc = ls(path) or ls('/404')

		global.flags.incr('fastscroll')
		setTimeout(&,500) do global.flags.decr('fastscroll')
		document.body.offsetHeight

		try
			document.documentElement.classList.toggle('noscroll',path.indexOf('/examples/') == 0)
		self

	def render
		if path != router.url.pathname
			go(router.url.pathname)

		let home? = router.match('/$')
		let repl? = router.match('/try')
		

		<self[d:contents]
			@run=runCodeBlock(e.detail)
			@showide=$repl.show!
			@showsearch=$search.show!
			.show-menu=($menu..focused?)
			>
			<div.header>
				css pos:fixed d:flex ai:center
					px:2 w:100% h:$header-height top:0px
					zi:300 fs:15px bg:cool8/98 c:white us:none

					
					.tab d:hflex mx:2 py:1 c:blue4 fs:sm- fw:500 tt:uppercase ja:center
						svg h:16px w:auto mx:0.5
						@hover c:white
							svg scale:1.15
						@!600 span d:none
						.keycap bc:blue4/70 c:blue4/80 h:4.5 px:0.75 fw:bold ml:0.5
					.toggler mx:0 d@md:none
						svg tween:styles 0.1s
						@hover c:blue4
							svg scale:1
						&.active svg rotate:-90deg

				<.logo[d:contents] route-to='/'>
					<svg[h:20px w:auto mr:2 pos:relative t:2px ml:1 c:blue4] src='./assets/wing.svg'>
					<.logotype[c:white fw:700 fs:xl lh:30px]> "imba"
				<.breadcrumb[mx:2 fs:sm c:blue4]>
					css span + span @before content: "/" mx:1 o:0.3
					<a[p:1 2 fw:600 ml:10px rd:12px bgc:hsla(213.12, 93.90%, 67.84%, 1) c:hsla(215.00, 27.91%, 16.86%, 98%) @hover:white d@lt-md:none] href="https://jobs.scrimba.com" title="well, actually Scrimba is hiring - but learn to code in Imba with pay! "> "We are hiring!"
						
						
				<div[flex: 1]>
					if window.debug
						<div @resize.silent=render> "{window.innerWidth}px"
				<div[d:flex cursor:pointer us:none]>
					<a.tab[mr:4] @click.emit-showsearch>
						<svg src='./assets/icons/search.svg'>
						<span[c:blue4/50 mx:0.5 tt:none]> "Search..."
						<span.keycap hotkey='s' @hotkey.prevent.emit-showsearch> 'S'
					if home?
						<a.tab @click.emit-showide href='/language/introduction'>
							<svg src='./assets/icons/book.svg'>
							<span> "Learn"
					<a.tab @click.emit-showide>
						<svg src='./assets/icons/play.svg'>
						<span> "Try"
					<a.tab target='_blank' href='https://discord.gg/mkcbkRw'>
						<svg src='./assets/icons/message-circle.svg'>
						<span> "Chat"
					<a.tab[ml:4] target='_blank' href='https://github.com/imba/imba'>
						<svg src='./assets/icons/github.svg'>
					<a.tab target='_blank' href='https://twitter.com/imbajs'>
						<svg src='./assets/icons/twitter.svg'>
					if !home?
						<a.tab.toggler
							.active=($menu..focused?)
							@mousedown.prevent=$menu.toggle!>
							<svg[h:32px] src='./assets/icons/menu.svg'>

			<app-repl$repl id='repl' fs=fs route='/try' .nokeys=!repl?>
			<app-search$search>
			
			if home?
				<home-page>
			elif doc
				<app-menu$menu>
				<app-document$doc[ml@md:$menu-width]  $key=doc.id  data=doc .nokeys=repl? hash=document.location.hash>
			# <app-document$doc[ml@md:$menu-width] data=doc .nokeys=repl>
			# <div.open-ide-button @click=$repl.show! hotkey='enter'> 'OPEN IDE'

imba.mount <app-root>
document.scrollingElement.scrollLeft = 0