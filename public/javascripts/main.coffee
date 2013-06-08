bgImages = [
	[1024, 768]
	[1280, 720]
	[1280, 800]
	[1280, 1024]
	[1366, 768]
	[1440, 900]
	[1600, 900]
	[1600, 1200]
	[1680, 1050]
	[1920, 1080]
	[1920, 1200]
	[2560, 1600]
]

getBgImage = ->
	bg = bgImages[0]
	for wh in bgImages
		if wh[0] is screen.width
			bg = wh
			if wh[1] is screen.height
				return wh
	return bg

document.documentElement.style.backgroundImage = 'url(images/bg/' + getBgImage().join('x') + '.jpg)'


byId = (id) ->
	return id if typeof id is 'object'
	document.getElementById id

show = (id) ->
	byId(id).style.display = ''

hide = (id) ->
	byId(id).style.display = 'none'

trim = (str) ->
	if str.trim?
		str.trim()
	else
		str.replace(/^\s+|\s+$/g,'')


showrl = ->
	show 'rl'

checkUsername = (len) ->
	lab = byId('unamelab').children
	hide lab[1]
	if byId('uname').value.length < len
		show lab[0]
	else
		hide lab[0]

kb = ''
kbfull = ''

tmp = []
for c in [48..57]
	tmp.push "<li>#{String.fromCharCode(c)}</li>"

kbfull = tmp.join ''
tmp.shift()
kb = tmp.join ''
tmp = []
ltmp = []

for c in [97..122]
	ch = String.fromCharCode c
	ltmp.push "<li>#{ch}</li>"
	tmp.push "<li>#{ch.toUpperCase()}</li>"

kb += ltmp.join ''
kbfull += ltmp.join ''
kbfull += tmp.join ''

ltmp = null
tmp = []

for c in [33..47].concat [58..64].concat [91..96].concat [123..126]
	if c is 95
		tmp.push "<li class=\"underscore\">#{String.fromCharCode(c)}</li>"
	else
		tmp.push "<li>#{String.fromCharCode(c)}</li>"

kbfull += tmp.join ''

tmp = null

(byId 'kb').innerHTML = '<ul>' + kb + '</ul>'
#(byId 'kbfull').innerHTML = '<ul>' + kbfull + '<li class="clear">DEL</li><li class="clear"><-</li></ul>'

unameFocused = false

(byId 'uname').onfocus = ->
	unameFocused = true
	show 'unamelab' if @value.length < 6
	show 'kb'

(byId 'pwd').onfocus = ->
	show 'pwdlab'

(byId 'pwd').onblur = ->
	hide 'pwdlab'

(byId 'pwd').onkeydown = (e) ->
	len = 7
	len = 9 if e.keyCode in [8, 46]
	if @value.length < len then show 'pwdlab' else hide 'pwdlab'
	true

(byId 'uname').onkeydown = (e) ->
	keyCode = e.keyCode
	console.log keyCode
	if keyCode is 9 and trim(@value).length > 5
		hide 'unamelab'
		hide 'kb'
		return true
	unless keyCode in [8, 35, 36, 37, 39, 46]
		if keyCode in [65..90] or keyCode in [97..122] or keyCode in [49..57]
			checkUsername 5
			pos = getCaretPosition @
			@value = [@value.slice(0, pos), String.fromCharCode(keyCode).toLowerCase(), @value.slice(pos)].join ''
			setCaretPosition @, pos + 1
		return false
	else
		checkUsername 7 if keyCode in [8, 46]

document.onclick = (e) ->
	uname = byId 'uname'
	if unameFocused and trim(uname.value).length < 6
		uname.focus()
		return false
	id = e.target.id or ''
	tag = e.target.tagName.toLowerCase()
	if tag is 'input' and id isnt 'uname'
		hide 'unamelab'
		hide 'kb'
		unameFocused = false
	return true

(byId 'kb').onclick = (e) ->
	checkUsername 5
	uname = byId 'uname'
	if e.target.tagName.toLowerCase() is 'li'
		pos = getCaretPosition uname
		uname.value = [uname.value.slice(0, pos), trim(e.target.innerHTML), uname.value.slice(pos)].join ''
		setCaretPosition uname, pos + 1
	uname.focus()

valid = ->
	username = trim(byId('username').value)
	password = byId('password').value
	unless /^[a-z1-9]{6,}$/.test(username) and password.length > 7
		byId('signin_return').innerHTML = '<div class="re">Please enter the correct username & password!</div>'
		show 'signin_return'
		false
	else
		byId('signin_return').innerHTML = ''
		hide 'signin_return'
		true
signin = ->
	return unless valid()
	show 'loader'
	u = ['/signin?1=', byId('username').value, '&2=', encodeURIComponent(byId('password').value), '&3=', byId('remember').value]
	jsonp u.join(''), (err, data) ->
		if err?
			byId('loader').innerHTML = 'Timeout, please resubmit.'
		else
			if data.error?
				hide 'loader'
				signin_return = byId 'signin_return'
				signin_return.innerHTML = data.error
				show signin_return
			else
				byId('loader').innerHTML = 'Submitted successfully, now jump to ...'
				window.location = '/jump'


signup = ->
	pwd = byId('pwd')
	uname = byId('uname')
	if uname.value.length < 6
		uname.focus()
		return false
	else if pwd.value.length < 8
		pwd.focus()
		return false
	else
		show 'loader'
		u = ['/signup?1=', encodeURIComponent(byId('fname').value), '&2=', encodeURIComponent(byId('lname').value), '&3=', uname.value, '&4=', encodeURIComponent(pwd.value), '&5=', byId('rem').value]
		jsonp u.join(''), (err, data) ->
			if err?
				byId('loader').innerHTML = 'Timeout, please resubmit.'
			else
				hide 'loader'
				if data.error?
					signup_return = byId 'signup_return'
					signup_return.innerHTML = data.error
					show signup_return



# Jsonp

###
* Callback index.
###

count = 0

###
* Noop function.
###

noop = ->

###
* JSONP handler
*
* Options:
* - param {String} qs parameter (`callback`)
* - timeout {Number} how long after a timeout error is emitted (`60000`)
*
* @param {String} url
* @param {Object|Function} optional options / callback
* @param {Function} optional callback
###

jsonp = (url, opts, fn) ->
  if ('function' is typeof opts)
    fn = opts
    opts = {}

  {param, timeout} = opts
  param = param or 'callback'
  timeout = timeout or 60000
  enc = encodeURIComponent
  target = document.getElementsByTagName('script')[0]

  # generate a unique id for this request
  id = count++

  if (timeout)
    timer = setTimeout (->
      cleanup()
      fn and fn new Error('Timeout'))
    , timeout

  cleanup = ->
    script.parentNode.removeChild script
    window['__jp' + id] = noop

  window['__jp' + id] = (data) ->
    console.log('jsonp got', data)
    if timer then clearTimeout timer
    cleanup()
    fn and fn null, data

  # add qs component
  url += (if url.indexOf('?') > -1 then '&' else '?') + param + '=' + enc('__jp' + id + '')
  url = url.replace('?&', '?')

  console.log('jsonp req "%s"', url)

  # create script
  script = document.createElement('script')
  script.src = url
  target.parentNode.insertBefore(script, target)


###

** Returns the caret (cursor) position of the specified text field.
** Return value range is 0-oField.value.length.

###

getCaretPosition = (oField) ->

  # Initialize
  iCaretPos = 0

  # IE Support
  if document.selection

    # Set focus on the element
    oField.focus()

    # To get cursor position, get empty selection range
    oSel = document.selection.createRange()

    # Move selection start to 0 position
    oSel.moveStart('character', -oField.value.length)

    # The caret position is selection length
    iCaretPos = oSel.text.length

  # Firefox support
  else if oField.selectionStart or oField.selectionStart.toString() is '0'
    iCaretPos = oField.selectionStart

  # Return results
  iCaretPos


setCaretPosition = (el, caretPos) ->
    if el.createTextRange?
        range = el.createTextRange()
        range.move 'character', caretPos
        range.select()
    else
        if el.selectionStart
            el.focus()
            el.setSelectionRange caretPos, caretPos
        else
            elem.focus()