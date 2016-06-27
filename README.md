fuse-touchid [![Build Status](https://travis-ci.org/bolav/fuse-touchid.svg?branch=master)](https://travis-ci.org/bolav/fuse-touchid) ![Fuse Version](http://fuse-version.herokuapp.com/?repo=https://github.com/bolav/fuse-touchid)
============

![Screenshot](https://raw.githubusercontent.com/bolav/fuse-touchid/master/touch.png)

## Installation

Using [fusepm](https://github.com/bolav/fusepm)

    $ fusepm install https://github.com/bolav/fuse-touchid


## Usage

```
<iOSFingerPrint ux:Global="FingerPrint" />
<JavaScript>
	var fp = require('FingerPrint');
	function auth () {
		console.log("auth");
		fp.auth("We need your fingerprint.", function (success, reason) { if (success) { console.log("We are okay"); } console.log("s: " + success + "("+ reason +")"); });
	}
	module.exports = {
		auth: auth
	};
</JavaScript>
```
