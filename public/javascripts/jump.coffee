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

hide byId('history').children[0]