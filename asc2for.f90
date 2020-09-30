! this program reads an .ops file and converts it to (ascii) formatted
! a header record is preceeded by a line containing the format of the header record
! and followed by a line containing the format of the data records
! Those two lines start with 'headerformat is ' and '  dataformat is ', resp.
! (spaces are significant)

! Gerard Cats, 22 August 2020

! The following list was taken from OPS m_aps.f90

character*22                                     :: comment                    ! comment in grid header
character*10                                     :: kmpnm                      ! component name (parameter name of grid values)
character*10                                     :: eenheid                    ! unit of parameter
character*10                                     :: oors                       ! origin of grid values
character*6                                      :: form                       ! format which is used to read grid values (?? is this used?)
integer*4                                        :: ij                         !
integer*4                                        :: inu1                       !
integer*4                                        :: inu2                       !
integer*4                                        :: inu3                       !
integer*4                                        :: kode                       !
integer*4                                        :: ierr  

! Local declarations 
parameter       (maxrecsize = 10000)
integer*2       :: igrid(maxrecsize)            ! To contain grid values if the values are int
real            :: rgrid(maxrecsize)            ! To contain grid values if the values are real
real            :: xorgl, yorgl, grixl, griyl   ! grid coordinates
integer*4       :: nrcol, nrrow                 ! grid dimensions
character*13    :: repform                      ! format of data
character*1     :: realorint                    ! first character of repform: are data real or int?
character(60)   :: headerfmt                    ! format of header
character*16    :: teststring                   ! format test string

! open and define header
open(1, iostat = ierr, form = 'formatted')
if (ierr.ne.0) then
   write(6,*) 'error when opening file 1 iostat=', ierr
endif

1 continue     ! read next grid

! start with header: read, check grid size, and write format strings
read(1, '(A16,A60)', end = 9000, iostat = ierr) teststring, headerfmt
if (ierr.ne.0) then
   write(6,*) 'error when reading format of header iostat=', ierr
endif
if ( teststring /= 'headerformat is ' ) then
   write(6,*) 'wrong header record :', teststring, headerfmt
   error stop
endif
 
read(1, iostat = ierr, fmt = headerfmt ) &
       ij,inu1,inu2,inu3,kmpnm, eenheid, oors, comment, form, kode, xorgl ,       &
               &  yorgl, nrcol, nrrow, grixl, griyl

if (ierr.ne.0) then
   write(6,*) 'error when reading header iostat=', ierr
endif

if ( nrcol > maxrecsize ) then
   write(6,*) 'maximum record size too small; it is ', maxrecsize, ', but we need at least ', nrcol
   stop
endif

write(6, fmt = headerfmt ) &
     ij,inu1,inu2,inu3,kmpnm, eenheid, oors, comment, form, kode, xorgl,          &
                &  yorgl, nrcol, nrrow, grixl, griyl
write(2) &
     ij,inu1,inu2,inu3,kmpnm, eenheid, oors, comment, form, kode, xorgl,          &
                &  yorgl, nrcol, nrrow, grixl, griyl

read(1, '(A16,A60)', iostat = ierr) teststring, repform
if (ierr.ne.0) then
   write(6,*) 'error when reading format of data iostat=', ierr
endif
if ( teststring /= '  dataformat is ' ) then
   write(6,*) 'wrong header record :', teststring, repform
   error stop
endif

! read data (distinction between real and int)
realorint = form

if ( realorint .eq. 'E' .or. realorint .eq. 'F' ) then
   do i=1,nrrow
       read(1, fmt = repform, iostat=ierr) (rgrid(j), j=1,nrcol)
       if (ierr.ne.0) then
           write(6,*) 'when reading row ', j, ' iostat=', ierr
       endif
       write( 2, iostat=ierr )(rgrid(j), j=1,nrcol)
       if (ierr.ne.0) then
           write(6,*) 'when writing file iostat=', ierr
       endif
   enddo
else if ( realorint .eq. 'I' ) then
   do i=1,nrrow
       read(1, fmt = repform, iostat=ierr) (igrid(j), j=1,nrcol)
       if (ierr.ne.0) then
           write(6,*) 'when reading row ', j, ' iostat=', ierr
       endif
       write( 2, iostat=ierr )(igrid(j), j=1,nrcol)
       if (ierr.ne.0) then
           write(6,*) 'when writing file iostat=', ierr
       endif
   enddo
else 
   write(6,*) 'unrecognised format string ', form
   error stop
endif

goto 1     ! read next grid
9000 continue
end
