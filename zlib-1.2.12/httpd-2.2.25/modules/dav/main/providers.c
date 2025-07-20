/* Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "apr_pools.h"
#include "apr_hash.h"
#include "ap_provider.h"
#include "mod_dav.h"

#define DAV_PROVIDER_GROUP "dav"

DAV_DECLARE(void) dav_register_provider(apr_pool_t *p, const char *name,
                                        const dav_provider *provider)
{
    ap_register_provider(p, DAV_PROVIDER_GROUP, name, "0", provider);
}

DAV_DECLARE(const dav_provider *) dav_lookup_provider(const char *name)
{
    return ap_lookup_provider(DAV_PROVIDER_GROUP, name, "0");
}
