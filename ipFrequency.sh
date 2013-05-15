#!/bin/sh

if [ "$1" != "" ] && [ "$2" != "" ]; then
    logfile="/data3/im-log/*.webim.log.imp.$1"
    interval=$2
else
    echo "***Usage:sh ipFrequency.sh date interval."
    echo "*****date format is YYYY-MM-DD."
    echo "*****interval is the ip time interval with minitues as a basic unit."
    echo "*****Eg:sh ipFrequency.sh 2013-05-12 5"
    exit
fi

cat $logfile | grep sendMsgOk | grep -v "fromUserId=0" |
grep "spamReasons=\[\]" | gawk -F"\t" 'BEGIN{interval='$interval'}
    function getIP(name){
        split(name, arr, "=");
        ip = arr[2];
        sub(/^[[:blank:]]*/, "", ip);#去除左空格
        sub(/[[:blank:]]*$/, "", ip);#去除右空格
        return ip;
    }

    function getMins(time){ #将时间转化为分钟数
        split(time, tarr, ":");
        return tarr[1]*60+tarr[2];
    }{

    mins = getMins($1);
    ip = getIP($20);
    mi[mins"_"ip] ++ ;

    #将ip映射到分钟数上    
    if(dict[mins] != 0){
        if(index(dict[mins],ip) == 0){
        	dict[mins] = dict[mins]","ip;
        }
    }else{
        dict[mins] = ip;
    }
}END{
    for(i = 0; i < 24 * 60; i++){
        #统计该时间间隔内的ip频率
        for(j = i; (j < i + interval) && (j < 24 * 60); j++){
           len = split(dict[j], ipArr, "," );#获取该分钟对应的ip列表
           for(k = 1; k <= len; k++) {
               ip = ipArr[k];
               fre[ip] += mi[j"_"ip];
               iplist[ip] ++; #将该时间段内出现的ip放到数组中
           }  
        }
        #更新ip对应的最大频率
        for(k in iplist){
           if(fre[k] > max[k]){
               max[k] = fre[k];
               mintime[k] = int(i/60)":"(i%60);
               maxtime[k] = int((i + interval)/60)":"((i+interval)%60);
           }
        }
        delete iplist;
        delete fre;
    }
    #输出ip最大频率
    for(k in max) {
        printf("%s-%s\t%s\t%d\n", mintime[k], maxtime[k], k, max[k]);
    }
}'
