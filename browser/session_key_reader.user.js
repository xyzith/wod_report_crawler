// ==UserScript==
// @name			WOD PHP Session key reader
// @namespace		ttang.tw
// updateURL	   https://bitbucket.org/Xyzith/wod_item_group/raw/sync/group.user.js
// @grant			none
// @author			Taylor Tang
// @version			1
// @description		Read session key for. DO NOT install this script if you don't know what it's for.
// @include			*://*.world-of-dungeons.org/*
// ==/UserScript==

function readCookie() {
	let cookies = document.cookie.match(/(\w+=\w+)/g);
	return cookies && cookies.reduce((cookie_json, cookie) => {
		return (([k, v]) => Object.assign(cookie_json, { [k]: v }))(cookie.split('='));
	}, {});
}

readCookie();
console.log(readCookie());
// TODO send to local server
