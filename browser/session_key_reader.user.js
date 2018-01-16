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

function xhr(url) {
	return new Promise((resolve, reject) => {
		var x = new XMLHttpRequest();
		x.open('GET', url);
		x.onload = () => resolve(x);
		x.send();
	});
}

function readCookie() {
	let cookies = document.cookie.match(/(\w+=\w+)/g) || [];
	return cookies.reduce((cookie_json, cookie) => {
		return (([k, v]) => Object.assign(cookie_json, { [k]: v }))(cookie.split('='));
	}, {});
}
function getTimmer() {
	const date = new Date();
	const current = date.valueOf();
	const button = document.querySelector('input.button_disabled');
	if (!button) { return 0 }

	const time = button.value.match(/\d+:\d+$/);
	if (!time) { return 0 }
	const [hour, minute] = time[0].split(':');
	date.setHours(hour);
	date.setMinutes(minute);
	if (date.valueOf() < current) {
		date.setTime(date.valueOf() + 86400000);
	}
	return Math.floor(date.valueOf() / 1000) + 300;
}

const cookies = readCookie();
const time = getTimmer();
const key = cookies.PHPSESSID
const login_CC = cookies.login_CC
if (time || key || login_CC) {
	xhr(`http://localhost/lua/wodreport.lua?key=${key}&login_CC=${login_CC}&time=${time || 0}`)
}

