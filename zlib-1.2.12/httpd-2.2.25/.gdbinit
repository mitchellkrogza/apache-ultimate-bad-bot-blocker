# gdb macros which may be useful for folks using gdb to debug
# apache.  Delete it if it bothers you.

define dump_table
    set $t = (apr_table_entry_t *)((apr_array_header_t *)$arg0)->elts
    set $n = ((apr_array_header_t *)$arg0)->nelts
    set $i = 0
    while $i < $n
	if $t[$i].val == (void *)0L
	   printf "[%u] '%s'=>NULL\n", $i, $t[$i].key
	else
	   printf "[%u] '%s'='%s'\n", $i, $t[$i].key, $t[$i].val
	end
	set $i = $i + 1
    end
end
document dump_table
    Print the key/value pairs in a table.
end


define rh
	run -f /home/dgaudet/ap2/conf/mpm.conf
end

define ro
	run -DONE_PROCESS
end

define dump_string_array
    set $a = (char **)((apr_array_header_t *)$arg0)->elts
    set $n = (int)((apr_array_header_t *)$arg0)->nelts
    set $i = 0
    while $i < $n
	printf "[%u] '%s'\n", $i, $a[$i]
	set $i = $i + 1
    end
end
document dump_string_array
    Print all of the elements in an array of strings.
end

define printmemn
    set $i = 0
    while $i < $arg1
        if $arg0[$i] < 0x20 || $arg0[$i] > 0x7e
            printf "~"
        else
            printf "%c", $arg0[$i]
        end
        set $i = $i + 1
    end
end

define print_bkt_datacol
    # arg0 == column name
    # arg1 == format
    # arg2 == value
    # arg3 == suppress header?
    set $suppressheader = $arg3

    if !$suppressheader
        printf " "
        printf $arg0
        printf "="
    else
        printf " | "
    end
    printf $arg1, $arg2
end

define dump_bucket_ex
    # arg0 == bucket
    # arg1 == suppress header?
    set $bucket = (struct apr_bucket *)$arg0
    set $sh = $arg1
    set $refcount = -1

    print_bkt_datacol "bucket" "%-9s" $bucket->type->name $sh
    printf "(0x%08lx)", (unsigned long)$bucket
    print_bkt_datacol "length" "%-6ld" (long)($bucket->length) $sh
    print_bkt_datacol "data" "0x%08lx" $bucket->data $sh

    if !$sh
        printf "\n    "
    end

    if (($bucket->type == &apr_bucket_type_eos)   || \
        ($bucket->type == &apr_bucket_type_flush))

        # metadata buckets, no content
        print_bkt_datacol "contents" "%c" ' ' $sh
        printf "                     "
        print_bkt_datacol "rc" "n/%c" 'a' $sh

    else
    if ($bucket->type == &ap_bucket_type_error)

        # metadata bucket, no content but it does have an error code in it
        print_bkt_datacol "contents" "%c" ' ' $sh
        set $status = ((ap_bucket_error *)$bucket->data)->status
        printf " (status=%3d)        ", $status
        print_bkt_datacol "rc" "n/%c" 'a' $sh

    else
    if (($bucket->type == &apr_bucket_type_file) || \
        ($bucket->type == &apr_bucket_type_pipe) || \
        ($bucket->type == &apr_bucket_type_socket))

        # buckets that contain data not in memory (ie not printable)

        print_bkt_datacol "contents" "[**unprintable**%c" ']' $sh
        printf "     "
        if $bucket->type == &apr_bucket_type_file
            set $refcount = ((apr_bucket_refcount *)$bucket->data)->refcount
            print_bkt_datacol "rc" "%d" $refcount $sh
        end

    else
    if (($bucket->type == &apr_bucket_type_heap)      || \
        ($bucket->type == &apr_bucket_type_pool)      || \
        ($bucket->type == &apr_bucket_type_mmap)      || \
        ($bucket->type == &apr_bucket_type_transient) || \
        ($bucket->type == &apr_bucket_type_immortal))

        # in-memory buckets

        if $bucket->type == &apr_bucket_type_heap
            set $refcount = ((apr_bucket_refcount *)$bucket->data)->refcount
            set $p = (apr_bucket_heap *)$bucket->data
            set $data = $p->base+$bucket->start

        else
        if $bucket->type == &apr_bucket_type_pool
            set $refcount = ((apr_bucket_refcount *)$bucket->data)->refcount
            set $p = (apr_bucket_pool *)$bucket->data
            if !$p->pool
                set $p = (apr_bucket_heap *)$bucket->data
            end
            set $data = $p->base+$bucket->start

        else
        if $bucket->type == &apr_bucket_type_mmap
            # is this safe if not APR_HAS_MMAP?
            set $refcount = ((apr_bucket_refcount *)$bucket->data)->refcount
            set $p = (apr_bucket_mmap *)$bucket->data
            set $data = ((char *)$p->mmap->mm)+$bucket->start

        else
        if (($bucket->type == &apr_bucket_type_transient) || \
            ($bucket->type == &apr_bucket_type_immortal))
            set $data = ((char *)$bucket->data)+$bucket->start

        end
        end
        end
        end

        if $sh
            printf " | ["
        else
            printf " contents=["
        end
        set $datalen = $bucket->length
        if $datalen > 17
            printmem $data 17
            printf "..."
            set $datalen = 20
        else
            printmemn $data $datalen
        end
        printf "]"
        while $datalen < 20
            printf " "
            set $datalen = $datalen + 1
        end

        if $refcount != -1
            print_bkt_datacol "rc" "%d" $refcount $sh
        else
            print_bkt_datacol "rc" "n/%c" 'a' $sh
        end

    else
        # 3rd-party bucket type
        print_bkt_datacol "contents" "[**unknown**%c" ']' $sh
        printf "         "
        print_bkt_datacol "rc" "n/%c" 'a' $sh
    end
    end
    end
    end

    printf "\n"

end

define dump_bucket
    dump_bucket_ex $arg0 0
end
document dump_bucket
    Print bucket info
end

define dump_brigade
    set $bb = (apr_bucket_brigade *)$arg0
    set $bucket = $bb->list.next
    set $sentinel = ((char *)((&($bb->list)) \
                               - ((size_t) &((struct apr_bucket *)0)->link)))
    printf "dump of brigade 0x%lx\n", (unsigned long)$bb

    printf "   | type     (address)    | length | "
    printf "data addr  | contents               | rc\n"
    printf "----------------------------------------"
    printf "----------------------------------------\n"

    if $bucket == $sentinel
        printf "brigade is empty\n"
    end

    set $j = 0
    while $bucket != $sentinel
        printf "%2d", $j
        dump_bucket_ex $bucket 1
        set $j = $j + 1
        set $bucket = $bucket->link.next
    end
    printf "end of brigade\n"
end
document dump_brigade
    Print bucket brigade info
end

define dump_filters
    set $f = $arg0
    while $f
        printf "%s(0x%lx): ctx=0x%lx, r=0x%lx, c=0x%lx\n", \
        $f->frec->name, (unsigned long)$f, (unsigned long)$f->ctx, \
        $f->r, $f->c
        set $f = $f->next
    end
end
document dump_filters
    Print filter chain info
end

define dump_process_rec
    set $p = $arg0
    printf "process_rec=0x%lx:\n", (unsigned long)$p
    printf "   pool=0x%lx, pconf=0x%lx\n", \
           (unsigned long)$p->pool, (unsigned long)$p->pconf
end
document dump_process_rec
    Print process_rec info
end

define dump_server_rec
    set $s = $arg0
    printf "name=%s:%d\n", \
            $s->server_hostname, $s->port
    dump_process_rec($s->process)
end
document dump_server_rec
    Print server_rec info
end

define dump_servers
    set $s = $arg0
    while $s
        dump_server_rec($s)
        printf "\n"
        set $s = $s->next
    end
end
document dump_servers
    Print server_rec list info
end
