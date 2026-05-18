//
//  TestConstants.swift
//  SwByeDPI
//
//  Created by developer on 09.03.2026.
//

import Foundation
@testable import SwByeDPI

final class TestConstants {
    
    static let builtInStrategies: [Set<SBDStrategy>] = [
        BuiltInDPIeStrategies.strategiesList.strategies,
        ExternalDPIeStrategies.strategiesList.strategies,
    ]
    
    nonisolated(unsafe) static let androidBBDConfigDict: [String: Any] = [
        "app": "io.github.romanvht.byedpi",
        "version":"1.7.3",
        "apps": [
           "com.google.android.youtube",
           "com.brave.browser"
        ],
        "domainLists": [
           [
              "domains":[
                 "cloudflare.net",
                 "cloudflare.com",
                 "cloudflarecn.net",
                 "cloudflare-ech.com"
              ],
              "id":"cloudflare",
              "isActive":false,
              "isBuiltIn":true,
              "name":"Cloudflare"
           ],
           [
              "domains":[
                 "dis.gd",
                 "discord.co",
                 "discord.gg",
                 "discord.app",
                 "discord.com",
                 "discord.dev",
                 "discord.new",
                 "discord.gift",
                 "discord.gifts",
                 "discord.media",
                 "discord.store",
                 "discord.design",
                 "discordapp.com",
                 "discordcdn.com",
                 "discordsez.com",
                 "discordsays.com",
                 "discordmerch.com",
                 "discordpartygames.com",
                 "discordactivities.com",
                 "stable.dl2.discordapp.net",
                 "discord-attachments-uploads-prd.storage.googleapis.com"
              ],
              "id":"discord",
              "isActive":false,
              "isBuiltIn":true,
              "name":"Discord"
           ],
           [
              "domains":[
                 "rutracker.org",
                 "nyaa.si",
                 "rutor.org",
                 "nnmclub.to",
                 "speedtest.net",
                 "ookla.com"
              ],
              "id":"general",
              "isActive":true,
              "isBuiltIn":true,
              "name":"General"
           ],
           [
              "domains":[
                 "rr1---sn-4axm-n8vs.googlevideo.com",
                 "rr1---sn-gvnuxaxjvh-o8ge.googlevideo.com",
                 "rr1---sn-ug5onuxaxjvh-p3ul.googlevideo.com",
                 "rr1---sn-ug5onuxaxjvh-n8v6.googlevideo.com",
                 "rr4---sn-q4flrnsl.googlevideo.com",
                 "rr10---sn-gvnuxaxjvh-304z.googlevideo.com",
                 "rr14---sn-n8v7kn7r.googlevideo.com",
                 "rr16---sn-axq7sn76.googlevideo.com",
                 "rr1---sn-8ph2xajvh-5xge.googlevideo.com",
                 "rr1---sn-gvnuxaxjvh-5gie.googlevideo.com",
                 "rr12---sn-gvnuxaxjvh-bvwz.googlevideo.com",
                 "rr5---sn-n8v7knez.googlevideo.com",
                 "rr1---sn-u5uuxaxjvhg0-ocje.googlevideo.com",
                 "rr2---sn-q4fl6ndl.googlevideo.com",
                 "rr5---sn-gvnuxaxjvh-n8vk.googlevideo.com",
                 "rr4---sn-jvhnu5g-c35d.googlevideo.com",
                 "rr1---sn-q4fl6n6y.googlevideo.com",
                 "rr2---sn-hgn7ynek.googlevideo.com",
                 "rr1---sn-xguxaxjvh-gufl.googlevideo.com"
              ],
              "id":"googlevideo",
              "isActive":true,
              "isBuiltIn":true,
              "name":"Googlevideo"
           ],
           [
              "domains":[
                 "snapchat.com",
                 "snap.com",
                 "linkedin.com",
                 "facebook.com",
                 "fb.com",
                 "fb.me",
                 "fbcdn.net",
                 "messenger.com",
                 "meta.com",
                 "instagram.com",
                 "static.cdninstagram.com",
                 "proton.me",
                 "medium.com",
                 "x.com",
                 "twitter.com",
                 "soundcloud.com",
                 "telegram.org",
                 "whatsapp.com"
              ],
              "id":"social",
              "isActive":true,
              "isBuiltIn":true,
              "name":"Social"
           ],
           [
              "domains":[
                 "youtu.be",
                 "youtube.com",
                 "i.ytimg.com",
                 "i9.ytimg.com",
                 "yt3.ggpht.com",
                 "yt4.ggpht.com",
                 "googleapis.com",
                 "jnn-pa.googleapis.com",
                 "googleusercontent.com",
                 "signaler-pa.youtube.com",
                 "youtubei.googleapis.com",
                 "manifest.googlevideo.com",
                 "yt3.googleusercontent.com"
              ],
              "id":"youtube",
              "isActive":true,
              "isBuiltIn":true,
              "name":"Youtube"
           ],
           [
              "domains":[
                 "rutor.info",
                 "rutor.org",
                 "rutracker.org",
                 "nnm-club-me.ru",
                 "rustorka.com",
                 "fast-torrent.ru",
                 "thepiratebay.org",
                 "1337x.to",
                 "medium.com",
                 "x.com",
                 "twitter.com",
                 "instagram.com",
                 "m.facebook.com",
                 "linkedin.com",
                 "patreon.com",
                 "metacritic.com",
                 "lib.rus.ec",
                 "flibusta.is",
                 "flibs.me",
                 "flisland.net",
                 "flibusta.site",
                 "rezka.ag",
                 "hdrezka.ag",
                 "hdrezka.me",
                 "filmix.co",
                 "filmix.cc",
                 "lostfilm.tv",
                 "kinozal.tv",
                 "kinokrad.cc",
                 "seasonvar.ru",
                 "protonvpn.com",
                 "proton.me",
                 "drive.proton.me",
                 "torproject.org",
                 "check.torproject.org"
              ],
              "id":"custom",
              "isActive":true,
              "isBuiltIn":false,
              "name":"Custom"
           ]
        ],
        "history":[
           [
              "pinned":true,
              "text":"-s1 -q1 -a1 -Y -Ar -a1 -s5 -o2 -At -f-1 -r1+s -a1 -As -s1 -o1+s -s-1 -a1"
           ],
           [
              "pinned":true,
              "text":"-d1 -s1 -q1 -Y -a1 -Ar -s5 -o1+s -d3+s -s6+s -d9+s -s12+s -d15+s -s20+s -d25+s -s30+s -d35+s -a1"
           ],
           [
              "pinned":true,
              "text":"-o1 -a1 -At,r,s -f-1 -a1 -At,r,s -d1:11+sm -S -a1 -At,r,s -n ya.ru -Qr -f1 -d1:11+sm -s1:11+sm -S -a1"
           ]
        ],
        "settings":[
           "byedpi_proxytest_logclickable":false,
           "byedpi_proxytest_domain_lists":[
              "youtube",
              "general",
              "discord",
              "social",
              "custom",
              "googlevideo"
           ],
           "byedpi_proxytest_requestsсount":"2",
           "byedpi_http_connect":false,
           "language":"system",
           "autostart":true,
           "byedpi_proxy_port":"1080",
           "byedpi_proxytest_requests":"2",
           "dns_ip":"8.8.8.8",
           "byedpi_proxytest_sni":"google.com",
           "auto_connect":true,
           "byedpi_proxytest_gdomain":true,
           "byedpi_proxytest_limit":"10",
           "byedpi_proxytest_domains":"rutor.info\nrutor.org\nrutracker.org\nnnm-club-me.ru\nrustorka.com\nfast-torrent.ru\nthepiratebay.org\n1337x.to\nmedium.com\nx.com\ntwitter.com\ninstagram.com\nm.facebook.com\nlinkedin.com\npatreon.com\nmetacritic.com\nlib.rus.ec\nflibusta.is\nflibs.me\nflisland.net\nflibusta.site\nrezka.ag\nhdrezka.ag\nhdrezka.me\nfilmix.co\nfilmix.cc\nlostfilm.tv\nkinozal.tv\nkinokrad.cc\nseasonvar.ru\nprotonvpn.com\nproton.me\ndrive.proton.me\ntorproject.org\ncheck.torproject.org\nxvideos.com\nxv-ru.com\ntnaflix.com\nsxyprn.net\neporner.com\nxhamster.com\nporntrex.com\nxfree.com\nleakedzone.com\nerome.com\ndirtyship.com\ntwpornstars.com\nthothub.to\nthothub.lol\nyouporn.com\nhqporner.com\nhotleaks.tv\nplayvids.com\nvxxx.com\nwhoreshub.com\ntxxx.com\nveryfreeporn.com\ntrendyporn.com",
           "ipv6_enable":false,
           "byedpi_proxy_ip":"127.0.0.1",
           "domain_initial_loaded":true,
           "app_theme":"system",
           "is_test_running":false,
           "applist_type":"whitelist",
           "byedpi_proxytest_usercommands":false,
           "byedpi_cmd_args":"-s1 -q1 -a1 -Y -Ar -a1 -s5 -o2 -At -f-1 -r1+s -a1 -As -s1 -o1+s -s-1 -a1",
           "byedpi_proxytest_delay":"1",
           "byedpi_proxytest_timeout":"3",
           "byedpi_enable_cmd_settings":true,
           "byedpi_mode":"vpn"
        ],
    ]
    
    static let strategies = SBDStrategyList(name: "built-in", strategies: [
        SBDStrategy(cmdArgs: ["-n", "{sni}", "-s1", "-d1", "-r1+s", "-a1", "-Ar", "-o1", "-a1", "-At", "-r1+s", "-a1"]),
        SBDStrategy(cmdArgs: ["-n", "google.com", "-d1", "-s1+s", "-r1+s", "-e1", "-m1", "-o1+s", "-t2", "-a1"]),
        SBDStrategy(cmdArgs: ["-n", "{sni}", "-s1", "-q1", "-a1", "-Ar", "-a1", "-s5", "-o2", "-At", "-r1+s", "-a1", "-As", "-s1", "-o1+s", "-s-1", "-a1"]),
    ])
    
    static let domainLists: [String: SBDDomainList] = [
        "youtube": SBDDomainList(name: "Youtube", domains: Set<String>([
            "youtube.com",
            "youtu.be",
            "i.ytimg.com",
        ])),
        "googlevideo": SBDDomainList(name: "GoogleVideo", domains: Set<String>([
            "googleapis.com",
            "googlevideo.com",
            "rr2---sn-hgn7ynek.googlevideo.com",
            "rr1---sn-xguxaxjvh-gufl.googlevideo.com",
            "rri---sn-gvnuxaxjvh-5gie.googlevideo.com",
        ])),
        "facebook": SBDDomainList(name: "Facebook", domains: Set<String>([
            "facebook.com",
            "fb.com",
            "meta.com",
            "b-graph.facebook.com",
        ])),
        "instagram": SBDDomainList(name: "Instagram", domains: Set<String>([
            "instagram.com",
            "static.cdninstagram.com",
            "instagram.c10r.instagram.com",
            "cdninstagram.com",
        ])),
        "discord": SBDDomainList(name: "Discord", domains: Set<String>([
            "discord.app",
            "discord.com",
        ])),
        "twitch": SBDDomainList(name: "Twitch", domains: Set<String>([
            "twitch.tv",
            "ttvnw.net",
        ])),
        "telegram": SBDDomainList(name: "Telegram", domains: Set<String>([
            "telegram.org",
            "t.me",
        ])),
        "book": SBDDomainList(name: "Book", domains: Set<String>([
            "lib.rus.ec",
            "flibusta.is",
        ]))
    ]
    
    static let testResults = [
        // 1st strat: pass yt, twitch, discord, tg, book (3 per-domain requests)
        SBDStrategyTestResult(strategy: SBDStrategy(cmdArgs: ["-n", "{sni}", "-s1", "-d1", "-r1+s", "-a1", "-Ar", "-o1", "-a1", "-At", "-r1+s", "-a1"]), domainsTestResult: [
            "youtube.com": SBDDomainTestResult(domain: "youtube.com", successRequestsCount: 3, failedRequestsCount: 0),
            "youtu.be": SBDDomainTestResult(domain: "youtu.be", successRequestsCount: 2, failedRequestsCount: 1),
            "i.ytimg.com": SBDDomainTestResult(domain: "i.ytimg.com", successRequestsCount: 2, failedRequestsCount: 1),
            
            "googleapis.com": SBDDomainTestResult(domain: "googleapis.com", successRequestsCount: 1, failedRequestsCount: 2),
            "googlevideo.com": SBDDomainTestResult(domain: "googlevideo.com", successRequestsCount: 2, failedRequestsCount: 1),
            "rr2---sn-hgn7ynek.googlevideo.com": SBDDomainTestResult(domain: "rr2---sn-hgn7ynek.googlevideo.com", successRequestsCount: 1, failedRequestsCount: 2),
            "rr1---sn-xguxaxjvh-gufl.googlevideo.com": SBDDomainTestResult(domain: "rr1---sn-xguxaxjvh-gufl.googlevideo.com", successRequestsCount: 0, failedRequestsCount: 3),
            "rri---sn-gvnuxaxjvh-5gie.googlevideo.com": SBDDomainTestResult(domain: "rri---sn-gvnuxaxjvh-5gie.googlevideo.com", successRequestsCount: 0, failedRequestsCount: 3),
            
            "facebook.com": SBDDomainTestResult(domain: "facebook.com", successRequestsCount: 0, failedRequestsCount: 3),
            "fb.com": SBDDomainTestResult(domain: "fb.com", successRequestsCount: 0, failedRequestsCount: 3),
            "meta.com": SBDDomainTestResult(domain: "meta.com", successRequestsCount: 0, failedRequestsCount: 3),
            "b-graph.facebook.com": SBDDomainTestResult(domain: "b-graph.facebook.com", successRequestsCount: 0, failedRequestsCount: 3),
            
            "instagram.com": SBDDomainTestResult(domain: "instagram.com", successRequestsCount: 1, failedRequestsCount: 2),
            "static.cdninstagram.com": SBDDomainTestResult(domain: "static.cdninstagram.com", successRequestsCount: 1, failedRequestsCount: 2),
            "instagram.c10r.instagram.com": SBDDomainTestResult(domain: "instagram.c10r.instagram.com", successRequestsCount: 0, failedRequestsCount: 3),
            "cdninstagram.com": SBDDomainTestResult(domain: "cdninstagram.com", successRequestsCount: 1, failedRequestsCount: 2),
            
            "discord.app": SBDDomainTestResult(domain: "discord.app", successRequestsCount: 2, failedRequestsCount: 1),
            "discord.com": SBDDomainTestResult(domain: "discord.com", successRequestsCount: 3, failedRequestsCount: 0),
            
            "twitch.tv": SBDDomainTestResult(domain: "twitch.tv", successRequestsCount: 3, failedRequestsCount: 0),
            "ttvnw.net": SBDDomainTestResult(domain: "ttvnw.net", successRequestsCount: 2, failedRequestsCount: 1),
            
            "telegram.org": SBDDomainTestResult(domain: "telegram.org", successRequestsCount: 3, failedRequestsCount: 0),
            "t.me": SBDDomainTestResult(domain: "t.me", successRequestsCount: 2, failedRequestsCount: 1),
            
            "lib.rus.ec": SBDDomainTestResult(domain: "lib.rus.ec", successRequestsCount: 2, failedRequestsCount: 1),
            "flibusta.is": SBDDomainTestResult(domain: "flibusta.is", successRequestsCount: 2, failedRequestsCount: 1),
        ]),
        // 2nd strat: pass yt, googlevideo, facebook, twitch (2 per-domain requests)
        SBDStrategyTestResult(strategy: SBDStrategy(cmdArgs: ["-n", "google.com", "-d1", "-s1+s", "-r1+s", "-e1", "-m1", "-o1+s", "-t2", "-a1"]), domainsTestResult: [
            "youtube.com": SBDDomainTestResult(domain: "youtube.com", successRequestsCount: 1, failedRequestsCount: 1),
            "youtu.be": SBDDomainTestResult(domain: "youtu.be", successRequestsCount: 2, failedRequestsCount: 0),
            "i.ytimg.com": SBDDomainTestResult(domain: "i.ytimg.com", successRequestsCount: 1, failedRequestsCount: 1),
            
            "googleapis.com": SBDDomainTestResult(domain: "googleapis.com", successRequestsCount: 1, failedRequestsCount: 1),
            "googlevideo.com": SBDDomainTestResult(domain: "googlevideo.com", successRequestsCount: 2, failedRequestsCount: 0),
            "rr2---sn-hgn7ynek.googlevideo.com": SBDDomainTestResult(domain: "rr2---sn-hgn7ynek.googlevideo.com", successRequestsCount: 1, failedRequestsCount: 1),
            "rr1---sn-xguxaxjvh-gufl.googlevideo.com": SBDDomainTestResult(domain: "rr1---sn-xguxaxjvh-gufl.googlevideo.com", successRequestsCount: 2, failedRequestsCount: 0),
            "rri---sn-gvnuxaxjvh-5gie.googlevideo.com": SBDDomainTestResult(domain: "rri---sn-gvnuxaxjvh-5gie.googlevideo.com", successRequestsCount: 0, failedRequestsCount: 2),
            
            "facebook.com": SBDDomainTestResult(domain: "facebook.com", successRequestsCount: 1, failedRequestsCount: 1),
            "fb.com": SBDDomainTestResult(domain: "fb.com", successRequestsCount: 1, failedRequestsCount: 1),
            "meta.com": SBDDomainTestResult(domain: "meta.com", successRequestsCount: 1, failedRequestsCount: 1),
            "b-graph.facebook.com": SBDDomainTestResult(domain: "b-graph.facebook.com", successRequestsCount: 2, failedRequestsCount: 0),
            
            "instagram.com": SBDDomainTestResult(domain: "instagram.com", successRequestsCount: 0, failedRequestsCount: 2),
            "static.cdninstagram.com": SBDDomainTestResult(domain: "static.cdninstagram.com", successRequestsCount: 0, failedRequestsCount: 2),
            "instagram.c10r.instagram.com": SBDDomainTestResult(domain: "static.cdninstagram.com", successRequestsCount: 0, failedRequestsCount: 2),
            "cdninstagram.com": SBDDomainTestResult(domain: "static.cdninstagram.com", successRequestsCount: 0, failedRequestsCount: 2),
            
            "discord.app": SBDDomainTestResult(domain: "discord.app", successRequestsCount: 0, failedRequestsCount: 2),
            "discord.com": SBDDomainTestResult(domain: "discord.com", successRequestsCount: 0, failedRequestsCount: 2),
            
            "twitch.tv": SBDDomainTestResult(domain: "twitch.tv", successRequestsCount: 2, failedRequestsCount: 0),
            "ttvnw.net": SBDDomainTestResult(domain: "ttvnw.net", successRequestsCount: 1, failedRequestsCount: 1),
            
            "telegram.org": SBDDomainTestResult(domain: "telegram.org", successRequestsCount: 0, failedRequestsCount: 2),
            "t.me": SBDDomainTestResult(domain: "t.me", successRequestsCount: 0, failedRequestsCount: 2),
            
            "lib.rus.ec": SBDDomainTestResult(domain: "lib.rus.ec", successRequestsCount: 0, failedRequestsCount: 2),
            "flibusta.is": SBDDomainTestResult(domain: "flibusta.is", successRequestsCount: 0, failedRequestsCount: 2),
        ]),
        // 3rd strat: pass discord, tg (3 per-domain requests)
        SBDStrategyTestResult(strategy: SBDStrategy(cmdArgs: ["-n", "{sni}", "-s1", "-q1", "-a1", "-Ar", "-a1", "-s5", "-o2", "-At", "-r1+s", "-a1", "-As", "-s1", "-o1+s", "-s-1", "-a1"]), domainsTestResult: [
            "youtube.com": SBDDomainTestResult(domain: "youtube.com", successRequestsCount: 1, failedRequestsCount: 2),
            "youtu.be": SBDDomainTestResult(domain: "youtu.be", successRequestsCount: 0, failedRequestsCount: 3),
            "i.ytimg.com": SBDDomainTestResult(domain: "i.ytimg.com", successRequestsCount: 2, failedRequestsCount: 1),
            
            "googleapis.com": SBDDomainTestResult(domain: "googleapis.com", successRequestsCount: 1, failedRequestsCount: 2),
            "googlevideo.com": SBDDomainTestResult(domain: "googlevideo.com", successRequestsCount: 0, failedRequestsCount: 3),
            "rr2---sn-hgn7ynek.googlevideo.com": SBDDomainTestResult(domain: "rr2---sn-hgn7ynek.googlevideo.com", successRequestsCount: 1, failedRequestsCount: 2),
            "rr1---sn-xguxaxjvh-gufl.googlevideo.com": SBDDomainTestResult(domain: "rr1---sn-xguxaxjvh-gufl.googlevideo.com", successRequestsCount: 0, failedRequestsCount: 3),
            "rri---sn-gvnuxaxjvh-5gie.googlevideo.com": SBDDomainTestResult(domain: "rri---sn-gvnuxaxjvh-5gie.googlevideo.com", successRequestsCount: 0, failedRequestsCount: 3),
            
            "facebook.com": SBDDomainTestResult(domain: "facebook.com", successRequestsCount: 1, failedRequestsCount: 2),
            "fb.com": SBDDomainTestResult(domain: "fb.com", successRequestsCount: 0, failedRequestsCount: 3),
            "meta.com": SBDDomainTestResult(domain: "meta.com", successRequestsCount: 1, failedRequestsCount: 2),
            "b-graph.facebook.com": SBDDomainTestResult(domain: "b-graph.facebook.com", successRequestsCount: 0, failedRequestsCount: 3),
            
            "instagram.com": SBDDomainTestResult(domain: "instagram.com", successRequestsCount: 1, failedRequestsCount: 2),
            "static.cdninstagram.com": SBDDomainTestResult(domain: "static.cdninstagram.com", successRequestsCount: 1, failedRequestsCount: 2),
            "instagram.c10r.instagram.com": SBDDomainTestResult(domain: "static.cdninstagram.com", successRequestsCount: 0, failedRequestsCount: 3),
            "cdninstagram.com": SBDDomainTestResult(domain: "static.cdninstagram.com", successRequestsCount: 1, failedRequestsCount: 2),
            
            "discord.app": SBDDomainTestResult(domain: "discord.app", successRequestsCount: 2, failedRequestsCount: 1),
            "discord.com": SBDDomainTestResult(domain: "discord.com", successRequestsCount: 3, failedRequestsCount: 0),
            
            "twitch.tv": SBDDomainTestResult(domain: "twitch.tv", successRequestsCount: 1, failedRequestsCount: 2),
            "ttvnw.net": SBDDomainTestResult(domain: "ttvnw.net", successRequestsCount: 0, failedRequestsCount: 3),
            
            "telegram.org": SBDDomainTestResult(domain: "telegram.org", successRequestsCount: 2, failedRequestsCount: 1),
            "t.me": SBDDomainTestResult(domain: "t.me", successRequestsCount: 3, failedRequestsCount: 0),
            
            "lib.rus.ec": SBDDomainTestResult(domain: "lib.rus.ec", successRequestsCount: 1, failedRequestsCount: 2),
            "flibusta.is": SBDDomainTestResult(domain: "flibusta.is", successRequestsCount: 0, failedRequestsCount: 3),
        ]),
    ]
    
    static let expectedProfitStrategies = Set<SBDStrategy>([
        SBDStrategy(cmdArgs: ["-n", "{sni}", "-s1", "-d1", "-r1+s", "-a1", "-Ar", "-o1", "-a1", "-At", "-r1+s", "-a1"]),
        SBDStrategy(cmdArgs: ["-n", "google.com", "-d1", "-s1+s", "-r1+s", "-e1", "-m1", "-o1+s", "-t2", "-a1"])
    ])
    
    static let expectedUniversalStrategy = SBDStrategy(cmdArgs: ["-n", "{sni}", "-s1", "-d1", "-r1+s", "-a1", "-Ar", "-o1", "-a1", "-At", "-r1+s", "-a1"])
    
    fileprivate init() {}
}
