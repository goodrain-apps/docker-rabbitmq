#!/bin/bash
set -e

CONF_FILE="/etc/rabbitmq/rabbitmq.config"
DISK_LIMIT=
RABBITMQ_DEFAULT_USER=${RABBITMQ_USER:-admin}
RABBITMQ_DEFAULT_PASS=${RABBITMQ_PASS:-pass123465}


# 根据变量获取指定的配置文件并复制到配置目录
GetDiskLimit()
{
    # 如果没有设置MEMORY_SIZE变量直接退出
    if [ "$MEMORY_SIZE" == "" ];then
        echo "Must set MEMORY_SIZE environment variable! "
    exit 1
    else
        echo "memory type:$MEMORY_SIZE"

        case $MEMORY_SIZE in
        "micro")
          DISK_LIMIT="$((128*2))MB";;
        "small")
          DISK_LIMIT="$((256*2))MB";;
        "medium")
          DISK_LIMIT="$((512*2))MB";;
        "large")
          DISK_LIMIT="$((1*2))GB";;
        "2xlarge")
          DISK_LIMIT="$((2*2))GB";;
        "4xlarge")
          DISK_LIMIT="$((4*2))GB";;
        "8xlarge")
          DISK_LIMIT="$((8*2))GB";;
        "16xlarge")
          DISK_LIMIT="$((16*2))GB";;
        "32xlarge")
          DISK_LIMIT="$((32*2))GB";;
        "64xlarge")
          DISK_LIMIT="$((64*2))GB";;
        *)
          DISK_LIMIT="128MB";;
        esac
    fi
}

# 通过检查内存设置磁盘限制
GetDiskLimit

# If long & short hostnames are not the same, use long hostnames
if [ "$(hostname)" != "$(hostname -s)" ]; then
	export RABBITMQ_USE_LONGNAME=true
fi

if [ "$RABBITMQ_ERLANG_COOKIE" ]; then
	cookieFile='/var/lib/rabbitmq/.erlang.cookie'
	if [ -e "$cookieFile" ]; then
		if [ "$(cat "$cookieFile" 2>/dev/null)" != "$RABBITMQ_ERLANG_COOKIE" ]; then
			echo >&2
			echo >&2 "warning: $cookieFile contents do not match RABBITMQ_ERLANG_COOKIE"
			echo >&2
		fi
	else
		echo "$RABBITMQ_ERLANG_COOKIE" > "$cookieFile"
		chmod 600 "$cookieFile"
		chown rain "$cookieFile"
	fi
fi

if [ "$1" = 'rabbitmq-server' ]; then

    configs=(
        # https://www.rabbitmq.com/configure.html
        default_vhost
        default_user
        default_pass
    )

    haveConfig=
    for conf in "${configs[@]}"; do
        var="RABBITMQ_${conf^^}"
        val="${!var}"
        if [ "$val" ]; then
            haveConfig=1
            break
        fi
    done

    if [ "$haveConfig" ]; then
        cat > $CONF_FILE <<-'EOH'
            [
              {rabbit,
                [
	EOH
        
        if [ "$ssl" ]; then
		cat >> $CONF_FILE <<-EOS
		{ tcp_listeners, [ ] },
                { ssl_listeners, [ 5671 ] },
                { ssl_options,  [
                { certfile,   "$RABBITMQ_SSL_CERT_FILE" },
                { keyfile,    "$RABBITMQ_SSL_KEY_FILE" },
                { cacertfile, "$RABBITMQ_SSL_CA_FILE" },
                { verify,   verify_peer },
                { fail_if_no_peer_cert, true } ] },
		EOS
        else
		cat >> $CONF_FILE <<-EOS
                  { tcp_listeners, [ 5672 ] },
                  { ssl_listeners, [ ] },
		EOS
        fi
        
        for conf in "${configs[@]}"; do
            var="RABBITMQ_${conf^^}"
            val="${!var}"
            [ "$val" ] || continue
		cat >> $CONF_FILE <<-EOC
                  {$conf, <<"$val">>},
		EOC
        done
        cat >> $CONF_FILE <<-EOF
                  {vm_memory_high_watermark, 0.5},
                  {vm_memory_high_watermark_paging_ratio, 0.6},
                  {disk_free_limit, "$DISK_LIMIT"},
                  {loopback_users, []}
	EOF

        # If management plugin is installed, then generate config consider this
        if [ "$(rabbitmq-plugins list -m -e rabbitmq_management)" ]; then
            cat >> $CONF_FILE <<-'EOF'
                    ]
                  },
                  { rabbitmq_management, [
                      { listener, [
		EOF

            if [ "$ssl" ]; then
                cat >> $CONF_FILE <<-EOS
                      { port, 15671 },
                      { ssl, true },
                      { ssl_opts, [
                          { certfile,   "$RABBITMQ_SSL_CERT_FILE" },
                          { keyfile,    "$RABBITMQ_SSL_KEY_FILE" },
                          { cacertfile, "$RABBITMQ_SSL_CA_FILE" },
                      { verify,   verify_none },
                      { fail_if_no_peer_cert, false } ] } ] }
		EOS
            else
                cat >> $CONF_FILE <<-EOS
                        { port, 15672 },
                        { ssl, false }
                        ]
                      }
		EOS
            fi
        fi

        cat >> $CONF_FILE <<-'EOF'
                ]
              }
            ].
	EOF
    fi

    if [ "$ssl" ]; then
        # Create combined cert
        cat "$RABBITMQ_SSL_CERT_FILE" "$RABBITMQ_SSL_KEY_FILE" > /tmp/combined.pem
        chmod 0400 /tmp/combined.pem

        # More ENV vars for make clustering happiness
        # we don't handle clustering in this script, but these args should ensure
        # clustered SSL-enabled members will talk nicely
        export ERL_SSL_PATH="$(erl -eval 'io:format("~p", [code:lib_dir(ssl, ebin)]),halt().' -noshell)"
        export RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS="-pa '$ERL_SSL_PATH' -proto_dist inet_tls -ssl_dist_opt server_certfile /tmp/combined.pem -ssl_dist_opt server_secure_renegotiate true client_secure_renegotiate true"
        export RABBITMQ_CTL_ERL_ARGS="$RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS"
    fi


	chown -R rain /var/lib/rabbitmq
	set -- gosu rain "$@"
fi

exec "$@"
