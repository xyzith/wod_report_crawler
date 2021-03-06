// ==UserScript==
// @name            WOD PHP Session key reader
// @namespace       ttang.tw
// @updateURL       https://github.com/xyzith/wod_report_crawler/raw/master/browser/session_key_reader.user.js
// @grant           none
// @author          Taylor Tang
// @version         1.34
// @description     Read session key for. DO NOT install this script if you don't know what it's for.
// @include         *://*.world-of-dungeons.org/*
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
    // if server time != local pc time
    const hourOffset = 1;
    const current = new Date();
    const next = new Date(current + hourOffset);
    const button = document.querySelector('input.button_disabled');
    if (!button) { return 0; }

    const time = button.value.match(/\d+:\d+$/);
    if (!time) { return 0; }
    const [hour, minute] = time[0].split(':').map((n) => parseInt(n));
    next.setHours(hour + hourOffset);
    next.setMinutes(minute);
    if (current - next > 12 * 60 * 60 * 1000 ) {
        next.setTime(next.valueOf() + 86400000);
    }
    return Math.floor(next.valueOf() / 1000) + 90;
}

const cookies = readCookie();
const time = getTimmer();
const key = cookies.PHPSESSID;
const login_CC = cookies.login_CC;
const domain = 'localhost';
if (time || key || login_CC) {
    xhr(`http://${domain}/lua/wodreport.lua?key=${key}&login_CC=${login_CC}&time=${time || 0}`);
}

