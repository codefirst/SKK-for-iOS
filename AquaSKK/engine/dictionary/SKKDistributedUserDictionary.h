/* -*- C++ -*-

  MacOS X implementation of the SKK input method.

  Copyright (C) 2010 Tomotaka SUWA <tomotaka.suwa@gmail.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/

#ifndef SKKDistributedUserDictionary_h
#define SKKDistributedUserDictionary_h

#include "SKKUserDictionary.h"
#include "socketutil.h"

class SKKDistributedUserDictionary : public SKKUserDictionary {
    net::socket::tcpstream server_;

public:
    // path の形式は port
    virtual void Initialize(const std::string& path);

    virtual void Find(const SKKEntry& entry, SKKCandidateSuite& result);
    virtual std::string ReverseLookup(const std::string& candidate);
    virtual void Complete(SKKCompletionHelper& helper);

    virtual void Register(const SKKEntry& entry, const SKKCandidate& candidate);
    virtual void Remove(const SKKEntry& entry, const SKKCandidate& candidate);

    virtual void SetPrivateMode(bool flag);
};

#endif
