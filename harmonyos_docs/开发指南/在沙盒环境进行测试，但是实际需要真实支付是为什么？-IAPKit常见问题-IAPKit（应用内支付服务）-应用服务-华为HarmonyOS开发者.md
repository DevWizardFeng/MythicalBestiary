<h1 _ngcontent-xar-c119="" class="doc-title ng-star-inserted" title="在沙盒环境进行测试，但是实际需要真实支付是为什么？"> 在沙盒环境进行测试，但是实际需要真实支付是为什么？ </h1>

<div _ngcontent-xar-c106="" auitextselectionexpansion="" class="markdown-body ng-star-inserted" style="position: relative;"> <div><p>有可能是debug包切换为release包之后，手机进程缓存没有失效导致。切换debug包和release包后，要保证进程缓存失效，比如锁屏5分钟或者重启。</p> </div> <div></div></div>