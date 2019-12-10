      program varify
!!   ����ң��-����۲��ֶ����������������ˮ������������ҵ��
!!   ���õ����̽�չ۲����ϣ�������ͬ����ң�в�Ʒ(�����¶ȡ���ˮ�����ܽ����������ȣ�

!!   ������ѻ������������Ȩ��֤���Ϊ���������ֵ�0546661�ţ�

!!   �ο����ף�
!!   [1]  �����,������,�����ԣ���. ����MODIS����������ȼ�̽�����ܽ���ֳ�. ��ѧͨ����2003,15:1680��1685.
!!   [2]  �����,����,����־����. ����ң���ٷ��������켼����ԭ��. ����: ��������磬2003��58��91.
!!   [3] ���˺꣬����£�����ԣ��. ��������PM10Ũ�ȿռ�ֲ��������ۺϱ�ַ���.Ӧ������ѧ��,2007��18(2):165-172 
!!   [4] ���˺�,�����,��ʤ����. ���������ȵ��Ǿ��ȷֲ�����������ң�У�����۲��ۺϱ�ַ���.�������뻷���о�, 2007,12(5):683-692 

	real,allocatable :: surval(:),satval(:,:),surlat(:),surlon(:)
    real,allocatable :: sat_raw_lat(:),sat_raw_lon(:),sat_raw_da(:),sat_raw_dire(:),sat_raw_sc(:)
    integer,allocatable ::surnumb(:)
    real,allocatable :: varify1(:,:),lon1(:,:),lat1(:,:)
    character rundate*12
	integer year,month,day,ihr,numb
    integer loc
    integer ix,iy
    integer is
    integer itimes
    character*12,allocatable :: times(:)
	character NCFILE*300, CUBEFILE*300,TIMEFILE*300, GRIDFILE*300, OBSFIE*300, RETFILE*300 
    ix=1
    iy=1
    
	!!! ��ȡ�������� 
!	NCFILE   = 'F:\11\mid\201709100700_ssi.txt'
!   CUBEFILE = 'F:\11\mid\201709100700_ssi_cubic.txt'
!   TIMEFILE = 'F:\11\mid\time_radiences.txt'
!   GRIDFILE = 'F:\11\mid\grid_info.txt'
!   OBSFIE   = 'F:\11\mid\201709100700_station_radiences.txt'
!   RETFILE  = 'F:\11\mid'

	call GETARG(1, NCFILE)   !NCԭʼ�ļ�
	call GETARG(2, CUBEFILE) !NC��ֵ�ļ�	
	call GETARG(3, TIMEFILE) !ʱ������
	call GETARG(4, GRIDFILE) !�������
	call GETARG(5, OBSFIE)   !�۲�����
    call GETARG(6, RETFILE)  !���Ŀ¼

 
    !!!---- ��ȡ��ֶ���ʱ�䣬��ʽ���£�
    open( 100, file=trim(adjustl(TIMEFILE)) ) 
	do i=1,1
	 read(100,*)itimes
    enddo
    allocate(times(itimes))	
	do i=2,itimes+1
	 i1=i-1
	 read(100,*)times(i1)
	enddo
	close(100)   
    print*,"reading total times end!"
 
 
 do 9999 it=1,itimes
  
    rundate=times(it)
	
	!!!---- ��ȡ����վ��۲����ϣ���ʽ���£�
	!!!     վ����
	!!!     վ���� ����  γ�� �۲�ֵ 
    open( 1, file=trim(adjustl(OBSFIE)) ) 
	do i=1,1
	 read(1,*)numb
    enddo
    allocate(surnumb(numb))
	allocate(surval(numb))
	allocate(surlat(numb))
	allocate(surlon(numb))
	do i=2,numb+1
	 i1=i-1
	 read(1,*)surnumb(i1),surlon(i1),surlat(i1),surval(i1)
	enddo
	close(1)
    print*,"reading surface station radiencs information end!"  
!!---- ��ȡ��ֳ�������Ϣ����ʽ���£�
!!     ���½�γ��   ���½Ǿ���  ���  X��������   Y��������  
!!------ end ---------------------------------------------------
	open(2,file=trim(adjustl(GRIDFILE)))
	read(2,*)rminlat,rminlon,disgrid,ii,jj
    close(2)
	print*,rminlat,rminlon,disgrid,ii,jj
!!!---- ��ȡ��ֵ��ÿ�����ľ�γ����Ϣ
    allocate(lon1(ii,jj))
	allocate(lat1(ii,jj))
    do j=1,jj
     do i=1,ii
        lat1(i,j)=rminlat+(j-1)*disgrid
        lon1(i,j)=rminlon+(i-1)*disgrid
     enddo
    enddo
    print*,"reading grid information end!"  
 !!---- ��ȡ������ֵ����ֳ������ϵ����ǹ۲����ϣ�
    
	open( 3,file=trim(adjustl(CUBEFILE)) )
	allocate(satval(ii,jj))
	allocate(varify1(ii,jj))
    do i=1,ii
	  read(3,*)(satval(i,j),j=1,jj)
	enddo
    close(3)
    print*,"reading interploated statllite radiencs information end!" 
 !!---- ���ñ�ֶ����ӳ���
	call varifysat(numb,surval,surlat,surlon,disgrid,rminlon,rminlat,satval,varify1,ii,jj)
    print*,"start saving!"
!----- �����ֶ��������grads�����Ƹ�ʽ
	print*, trim(adjustl(RETFILE))//'/'//rundate//'_varify.txt'
    open(30,file=trim(adjustl(RETFILE))//'/'//rundate//'_varify.txt')
    do i=1,ii
       do j=1,jj
          write(30,'(3f12.3)') lat1(i,j),lon1(i,j),varify1(i,j)
       enddo
    enddo 
    close(30)
    
!------��ȡԭʼ���������ڵ���۲�վλ�õ�ֵ
    open(50,file=trim(adjustl(NCFILE)))
    index_raw=0
    do	while(.not.eof(50))
        read(50,*)
        index_raw=index_raw+1
    enddo
       
    allocate(sat_raw_lat(index_raw))
    allocate(sat_raw_lon(index_raw))
    allocate(sat_raw_da(index_raw))
       
    rewind(50)
       
    do	ir=1,index_raw
        read(50,*) sat_raw_lon(ir),sat_raw_lat(ir),sat_raw_da(ir)!,sat_raw_dire(ir),sat_raw_sc(ir)
    enddo
    
    close(50)
!----- �����ֶ������(�ܷ���)  
	print*, trim(adjustl(RETFILE))//'/'//rundate//'_varify_stations.txt'
    open(70,file=trim(adjustl(RETFILE))//'/'//rundate//'_varify_stations.txt')
    write(70,*) "վ�� ���� γ�� ԭʼ���� ���ǲ�ֵ ��ֶ��� ����۲�\n"
    do is=1,numb       
        call findpoint_2(surlat(is),surlon(is),sat_raw_lat,sat_raw_lon,index_raw,loc)
        call findpoint(surlon(is),surlat(is),lon1,lat1,ii,jj,iii,jjj)
        write(70,'(i8,6f12.3)') surnumb(is),surlon(is),surlat(is),sat_raw_da(loc),satval(iii,jjj),varify1(iii,jjj),surval(is)
    enddo
    close(70)
    
!----- ����ԭʼ����������վ��λ�õĽ��(�ܷ��䡢ɢ����䡢ֱ�ӷ���)
	print*, trim(adjustl(RETFILE))//'/'//rundate//'_stations&satellites.txt'
    open(80,file=trim(adjustl(RETFILE))//'/'//rundate//'_stations&satellites.txt')
    ! write(80,*) "վ�� ���� γ�� �ܷ��� \n"
    do is=1,numb   
        call findpoint_2(surlat(is),surlon(is),sat_raw_lat,sat_raw_lon,index_raw-1,loc)
        write(80,'(i8,3f12.3)') surnumb(is),surlon(is),surlat(is),sat_raw_da(loc)
    enddo
    close(80)      
    print*,"end saving!"
	
    deallocate(surnumb)
	deallocate(surval)
	deallocate(surlat)
	deallocate(surlon)
	deallocate(satval)
	deallocate(varify1)
    deallocate(lat1)
    deallocate(lon1)
    deallocate(sat_raw_lat)
    deallocate(sat_raw_lon)
    deallocate(sat_raw_da)
    
    
9999 continue    
	end


  SUBROUTINE VARIFYSAT(numb,surval,rlat,rlon,disgrid,rminlon,rminlat,satval,varify,ii,jj)
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! This Program is used to read surface data(station format) 
!          and varify satellite data(grid format)
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! ii : the number of lat's dots
! jj : the number of lon's dots
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! dimension arrays for surface data
      dimension  surval(numb),rlat(numb),rlon(numb),surval1(numb)
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! dimension arrays for satellite data
      dimension  satval(ii,jj)
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! dimension arrays for datas after varify
      dimension  varify(ii,jj)
      dimension  arry(ii,jj),erry(numb)
      dimension  xg(ii),yg(jj)
      dimension nsj(numb),nsi(numb),st(ii,jj),enul(ii,jj)
!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      do i=1,ii
       xg(i)=rminlon+(i-1)*disgrid
      enddo
      do j=1,jj
       yg(j)=rminlat+(j-1)*disgrid
      enddo

      do i=1,numb
        surval1(i)=-9.999
      enddo
      do j=1,jj
      do i=1,ii
        varify(i,j)=-9.999
      enddo
      enddo

      do i=1,numb
        surval1(i)=surval(i)
      enddo

      call stt(nsi,nsj,rlon,rlat,numb,rminlon,rminlat,numb,disgrid)
!     write(*,'(7i4)')(nsi(i),i=1,numb)
!      write(*,'(7i4)')(nsj(i),i=1,numb)

      do j=1,jj
      do i=1,ii
        arry(i,j)=satval(i,j)
      enddo
      enddo
      do i=1,numb
        erry(i)=surval1(i)
      enddo
!      aaa=650
       aaa=500
      call nst(st,arry,erry,nsi,nsj,numb,ii,jj)
!      aaa=650
       aaa=500
      call eul(enul,arry,st,aaa,ii,jj)
      do i=1,ii
      do j=1,jj
        varify(i,j)=enul(i,j)
        if( varify(i,j).lt.0.0001 ) then
	    varify(i,j)=0.00001
	  endif
        if( satval(i,j).lt.0.0001 ) then
	    satval(i,j)=0.00001
	  endif
      enddo
      enddo

      end
!********************************************************************
        subroutine stt(nsi,nsj,rlon,rlat,irnu,west,orth,numb,dis)
        dimension nsi(numb),nsj(numb),rlon(numb),rlat(numb)
		 
        do i=1,irnu
          nsi(i)=INT((rlon(i)-west+0.5*dis)/dis)+1
          nsj(i)=INT((rlat(i)-orth+0.5*dis)/dis)+1
        enddo
        return
        end
!**********************************************************************
        subroutine nst(st,arry,erry,nsi,nsj,ienu,ii,jj)
        dimension st(ii,jj),arry(ii,jj),erry(ienu),nsi(ienu)
        dimension son(5000,5000),nsj(ienu)
        do 200 j=1,jj
        do 200 i=1,ii
        son(i,j)=0.
        st(i,j)=0.
 200    continue
        do 300 k=1,ienu
        nj=nsj(k)
        if( erry(k).ge.99.0 .or. erry(k).lt.0. .or.erry(k).eq.0. )then
          goto 300
        else
          son(nsi(k),nj)=erry(k)
          st(nsi(k),nj)=son(nsi(k),nj)-arry(nsi(k),nj)
        endif
 300    continue
        
        write(*,*)'subroutine nst',ienu
        write(*,'(10I8)')(nsi(k),k=1,6)
        write(*,'(10I8)')(nsj(k),k=1,6)
        write(*,'(10f8.3)')(erry(k),k=1,6)
        write(*,'(10f8.3)')(arry(nsi(k),nsj(k)),k=1,6)
        write(*,'(10f8.3)')(st(nsi(k),nsj(k)),k=1,6)
        return
        end       

!*********************************************************************
        subroutine eul(enu,arry,st,aaa,ii,jj)
        dimension enu(ii,jj),env(5000,5000),st(ii,jj),arry(ii,jj)
        dimension eu1(5000,5000)
        do 200 j=1,jj
        do 200 i=1,ii
        enu(i,j)=st(i,j)
        env(i,j)=0
        eu1(i,j)=0
 200    continue
        k=0
 500    continue
        k=k+1
        do 300 j=1,jj
        do 300 i=1,ii

        eu1(i,j)=enu(i,j)

        if((i .eq. 1) .or.(j .eq.1) .or.(i .eq. ii).or.(j .eq.jj))then
        env(i,j)=st(i,j)
        else
        ana=0
        if((st(i,j) .ne. 0.) .and.(arry(i,j) .ne. 0.))then
        ana=aaa
        endif
        eut=(enu(i-1,j)+enu(i+1,j)+enu(i,j-1)+enu(i,j+1))+ana*st(i,j)
        env(i,j)=eut/(4+ana)
        endif
 300    continue
        do 400 j=1,jj
        do 400 i=1,ii
        if((i .eq. 1) .or.(j .eq.1) .or.(i .eq. ii).or.(j .eq.jj))then
        enu(i,j)=st(i,j)
        else
        ana=0
        if((st(i,j) .ne. 0.) .and.(arry(i,j) .ne. 0.))then
        ana=aaa
        endif
        evt=(env(i-1,j)+env(i+1,j)+env(i,j-1)+env(i,j+1))+ana*st(i,j)
        enu(i,j)=evt/(4+ana)
        endif
 400    continue

        qmin=0.
        amin=0.
        do 450 j=1,jj
        do 450 i=1,ii
           qmin=qmin+(enu(i,j)-eu1(i,j))**2 
           amin=amin+(enu(i,j))**2
450     continue
        qmin=(qmin/(ii*jj*1.))**0.5
        amin=(amin/(ii*jj*1.))**0.5
        qam=qmin/amin
!       if(k.le.50000 .or. qam.ge.0.00001)goto 500
!       if(k.le.500000 )goto 500
!        if(qam.ge.0.00000001)goto 500
        if(qam.ge.0.001)goto 500
        write(*,*)'eul k,qam qmin amin', k,qam,qmin,amin
        do 600 j=1,jj
        do 600 i=1,ii
        enu(i,j)=enu(i,j)+arry(i,j)
 600    continue
        return
    end
!************************************************************************

    
    
    subroutine findpoint(surlon,surlat,xg,yg,ii,jj,iii,jjj)
real surlat,surlon,dif(ii,jj),mindif
real xg(ii,jj),yg(ii,jj),diflat(ii,jj),diflon(ii,jj)

do j=1,jj     
do i=1,ii
  diflon(i,j)=surlon-xg(i,j)
  diflat(i,j)=surlat-yg(i,j)
  dif(i,j)=sqrt(diflon(i,j)**2+diflat(i,j)**2)
enddo
enddo

mindif=dif(1,1)
do j=1,jj
do i=1,ii
 if(dif(i,j).le.mindif) then
   mindif=dif(i,j)
   i0=i
   j0=j
 endif
enddo
enddo

iii=i0
jjj=j0
return
end



    subroutine findpoint_2(surlat,surlon,sat_raw_lat,sat_raw_lon,index_raw,loc)

    real dif(index_raw),mindif,surlat,surlon
    real diflat(index_raw),diflon(index_raw),sat_raw_lat(index_raw),sat_raw_lon(index_raw)

    do i=1,index_raw
        diflon(i)=surlon-sat_raw_lon(i)
        diflat(i)=surlat-sat_raw_lat(i)
        dif(i)=sqrt(diflon(i)**2+diflat(i)**2)
    enddo

    mindif=dif(1)
    loc=1
    do i=1,index_raw
        if(dif(i).le.mindif) then
            mindif=dif(i)
            loc=i
        endif
    enddo

    return
    end